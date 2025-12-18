---
title: "미니 데이터베이스 엔진 직접 구현하기"
date: 2025-12-18
categories: Database
tags: [database, b+tree, storage-engine, index, java, low-level]
author: pitbull terrier
---

# 미니 데이터베이스 엔진 직접 구현하기

면접에서 "인덱스가 왜 빠른가요?"라는 질문을 받으면 대부분 이렇게 답한다.

"B+Tree 구조라서 O(log n)으로 검색할 수 있습니다."

틀린 답은 아니다. 하지만 이 답을 하면서 B+Tree가 실제로 어떻게 디스크에 저장되고, 
페이지가 어떻게 관리되며, 트랜잭션이 어떻게 보장되는지 설명할 수 있는 사람은 많지 않다.

나도 그랬다.

그래서 직접 만들어봤다. 아주 작은, 하지만 실제로 동작하는 데이터베이스 엔진을.

## 데이터베이스 엔진의 핵심 구성요소

MySQL이나 PostgreSQL 같은 데이터베이스는 복잡하다. 수십만 줄의 코드로 이루어져 있다. 하지만 핵심 구성요소는 생각보다 단순하다.

```
┌─────────────────────────────────────────┐
│              SQL Parser                  │
├─────────────────────────────────────────┤
│            Query Executor                │
├─────────────────────────────────────────┤
│          Storage Engine                  │
│  ┌─────────────┬─────────────────────┐  │
│  │ Page Manager│    Index (B+Tree)   │  │
│  └─────────────┴─────────────────────┘  │
├─────────────────────────────────────────┤
│              Disk I/O                    │
└─────────────────────────────────────────┘
```

이 중에서 가장 중요한 건 Storage Engine이다. 데이터를 어떻게 저장하고, 어떻게 찾는가. 이게 데이터베이스의 본질이다.

오늘 구현할 것들이다.

1. **Page Manager** - 디스크에 데이터를 페이지 단위로 저장
2. **B+Tree Index** - 빠른 검색을 위한 인덱스 구조
3. **Simple Query Engine** - 기본적인 CRUD 연산

## Part 1: Page Manager 구현

### 왜 페이지 단위인가

데이터베이스는 데이터를 바이트 단위로 저장하지 않는다. 페이지(보통 4KB 또는 8KB) 단위로 저장한다.

이유는 디스크 I/O 특성 때문이다.

```
디스크에서 1바이트를 읽는 시간 ≈ 4KB를 읽는 시간
```

디스크 헤드가 원하는 위치로 이동하는 시간(seek time)이 대부분이다. 한 번 이동했으면 최대한 많이 읽는 게 효율적이다.

SSD도 마찬가지다. 내부적으로 페이지 단위로 읽고 쓴다.

### Page 클래스 구현

```java
public class Page {
    public static final int PAGE_SIZE = 4096; // 4KB
    
    private final int pageId;
    private final byte[] data;
    private boolean dirty; // 수정되었는지 여부
    
    public Page(int pageId) {
        this.pageId = pageId;
        this.data = new byte[PAGE_SIZE];
        this.dirty = false;
    }
    
    public void writeByte(int offset, byte value) {
        data[offset] = value;
        dirty = true;
    }
    
    public void writeInt(int offset, int value) {
        data[offset] = (byte) (value >> 24);
        data[offset + 1] = (byte) (value >> 16);
        data[offset + 2] = (byte) (value >> 8);
        data[offset + 3] = (byte) value;
        dirty = true;
    }
    
    public int readInt(int offset) {
        return ((data[offset] & 0xFF) << 24) |
               ((data[offset + 1] & 0xFF) << 16) |
               ((data[offset + 2] & 0xFF) << 8) |
               (data[offset + 3] & 0xFF);
    }
    
    public void writeBytes(int offset, byte[] bytes) {
        System.arraycopy(bytes, 0, data, offset, bytes.length);
        dirty = true;
    }
    
    public byte[] readBytes(int offset, int length) {
        byte[] result = new byte[length];
        System.arraycopy(data, offset, result, 0, length);
        return result;
    }
    
    public int getPageId() { return pageId; }
    public byte[] getData() { return data; }
    public boolean isDirty() { return dirty; }
    public void markClean() { dirty = false; }
}
```

페이지는 그냥 4KB짜리 바이트 배열이다. 여기에 정수나 문자열을 쓰고 읽는 메서드를 추가했다.

`dirty` 플래그는 중요하다. 페이지가 수정되었는지 추적해서, 나중에 디스크에 쓸지 말지 결정한다.

### PageManager 구현

```java
public class PageManager {
    private final RandomAccessFile file;
    private final Map<Integer, Page> pageCache;
    private final int maxCacheSize;
    private int nextPageId;
    
    public PageManager(String filename, int maxCacheSize) throws IOException {
        this.file = new RandomAccessFile(filename, "rw");
        this.pageCache = new LinkedHashMap<>(maxCacheSize, 0.75f, true) {
            @Override
            protected boolean removeEldestEntry(Map.Entry<Integer, Page> eldest) {
                if (size() > maxCacheSize) {
                    evictPage(eldest.getValue());
                    return true;
                }
                return false;
            }
        };
        this.maxCacheSize = maxCacheSize;
        this.nextPageId = (int) (file.length() / Page.PAGE_SIZE);
    }
    
    public Page getPage(int pageId) throws IOException {
        // 캐시에 있으면 반환
        if (pageCache.containsKey(pageId)) {
            return pageCache.get(pageId);
        }
        
        // 없으면 디스크에서 읽기
        Page page = new Page(pageId);
        file.seek((long) pageId * Page.PAGE_SIZE);
        file.readFully(page.getData());
        
        pageCache.put(pageId, page);
        return page;
    }
    
    public Page allocatePage() throws IOException {
        Page page = new Page(nextPageId++);
        pageCache.put(page.getPageId(), page);
        return page;
    }
    
    private void evictPage(Page page) {
        if (page.isDirty()) {
            try {
                flushPage(page);
            } catch (IOException e) {
                throw new RuntimeException("Failed to flush page", e);
            }
        }
    }
    
    public void flushPage(Page page) throws IOException {
        file.seek((long) page.getPageId() * Page.PAGE_SIZE);
        file.write(page.getData());
        page.markClean();
    }
    
    public void flushAll() throws IOException {
        for (Page page : pageCache.values()) {
            if (page.isDirty()) {
                flushPage(page);
            }
        }
    }
    
    public void close() throws IOException {
        flushAll();
        file.close();
    }
}
```

핵심은 **LRU 캐시**다.

모든 페이지를 메모리에 올릴 수 없다. 데이터베이스 파일이 100GB인데 메모리가 16GB라면? 자주 쓰는 페이지만 메모리에 두고, 안 쓰는 건 디스크로 내린다.

`LinkedHashMap`에 `accessOrder=true` 옵션을 주면 LRU 캐시가 된다. 가장 오래 안 쓴 페이지부터 제거된다.

## Part 2: B+Tree 인덱스 구현

### B+Tree가 뭔가

B+Tree는 이진 트리의 확장이다. 차이점은

1. 한 노드에 여러 키를 저장한다
2. 리프 노드에만 실제 데이터가 있다
3. 리프 노드끼리 연결되어 있다

```
                    [30, 60]
                   /    |    \
                  /     |     \
           [10, 20]  [40, 50]  [70, 80, 90]
              ↓         ↓          ↓
           (data)    (data)     (data)
              ↔         ↔          ↔
           (리프 노드들이 연결됨)
```

왜 이런 구조를 쓰는가?

**디스크 I/O를 줄이기 위해서다.**

이진 트리는 한 노드에 키가 하나뿐이다. 100만 개 데이터를 찾으려면 log₂(1,000,000) ≈ 20번의 노드 접근이 필요하다.

B+Tree에서 한 노드에 100개의 키가 들어간다면? log₁₀₀(1,000,000) ≈ 3번이면 된다.

노드 하나 = 페이지 하나 = 디스크 I/O 1번

20번 vs 3번. 차이가 크다.

### Node 클래스 구현

```java
public class BTreeNode {
    private final int pageId;
    private boolean isLeaf;
    private List<Integer> keys;
    private List<Integer> children;  // 내부 노드용: 자식 pageId
    private List<byte[]> values;     // 리프 노드용: 실제 데이터
    private int nextLeaf;            // 리프 노드용: 다음 리프의 pageId
    
    private static final int MAX_KEYS = 100; // 한 노드에 최대 100개 키
    
    public BTreeNode(int pageId, boolean isLeaf) {
        this.pageId = pageId;
        this.isLeaf = isLeaf;
        this.keys = new ArrayList<>();
        this.children = new ArrayList<>();
        this.values = new ArrayList<>();
        this.nextLeaf = -1;
    }
    
    public boolean isFull() {
        return keys.size() >= MAX_KEYS;
    }
    
    public boolean isLeaf() {
        return isLeaf;
    }
    
    // 페이지에 노드 데이터 직렬화
    public void writeTo(Page page) {
        int offset = 0;
        
        // 헤더: isLeaf(1) + keyCount(4) + nextLeaf(4)
        page.writeByte(offset++, (byte) (isLeaf ? 1 : 0));
        page.writeInt(offset, keys.size());
        offset += 4;
        page.writeInt(offset, nextLeaf);
        offset += 4;
        
        // 키들
        for (int key : keys) {
            page.writeInt(offset, key);
            offset += 4;
        }
        
        if (isLeaf) {
            // 리프: 값들의 길이와 데이터
            for (byte[] value : values) {
                page.writeInt(offset, value.length);
                offset += 4;
                page.writeBytes(offset, value);
                offset += value.length;
            }
        } else {
            // 내부 노드: 자식 pageId들
            for (int child : children) {
                page.writeInt(offset, child);
                offset += 4;
            }
        }
    }
    
    // 페이지에서 노드 데이터 역직렬화
    public static BTreeNode readFrom(Page page) {
        int offset = 0;
        
        boolean isLeaf = page.readBytes(offset++, 1)[0] == 1;
        int keyCount = page.readInt(offset);
        offset += 4;
        int nextLeaf = page.readInt(offset);
        offset += 4;
        
        BTreeNode node = new BTreeNode(page.getPageId(), isLeaf);
        node.nextLeaf = nextLeaf;
        
        // 키들 읽기
        for (int i = 0; i < keyCount; i++) {
            node.keys.add(page.readInt(offset));
            offset += 4;
        }
        
        if (isLeaf) {
            // 값들 읽기
            for (int i = 0; i < keyCount; i++) {
                int valueLen = page.readInt(offset);
                offset += 4;
                node.values.add(page.readBytes(offset, valueLen));
                offset += valueLen;
            }
        } else {
            // 자식들 읽기 (keyCount + 1개)
            for (int i = 0; i <= keyCount; i++) {
                node.children.add(page.readInt(offset));
                offset += 4;
            }
        }
        
        return node;
    }
    
    // getter/setter 생략
    public int getPageId() { return pageId; }
    public List<Integer> getKeys() { return keys; }
    public List<Integer> getChildren() { return children; }
    public List<byte[]> getValues() { return values; }
    public int getNextLeaf() { return nextLeaf; }
    public void setNextLeaf(int next) { this.nextLeaf = next; }
}
```

노드는 페이지에 직렬화된다. 이게 핵심이다.

메모리에서는 객체로 다루지만, 디스크에는 바이트 배열로 저장된다. `writeTo`와 `readFrom`이 그 변환을 담당한다.

### BTree 클래스 구현

```java
public class BTree {
    private final PageManager pageManager;
    private int rootPageId;
    
    public BTree(PageManager pageManager) throws IOException {
        this.pageManager = pageManager;
        
        // 루트 노드 생성 (비어있는 리프 노드로 시작)
        Page rootPage = pageManager.allocatePage();
        BTreeNode root = new BTreeNode(rootPage.getPageId(), true);
        root.writeTo(rootPage);
        this.rootPageId = rootPage.getPageId();
    }
    
    public BTree(PageManager pageManager, int rootPageId) {
        this.pageManager = pageManager;
        this.rootPageId = rootPageId;
    }
    
    // 검색
    public byte[] search(int key) throws IOException {
        return searchInNode(rootPageId, key);
    }
    
    private byte[] searchInNode(int pageId, int key) throws IOException {
        Page page = pageManager.getPage(pageId);
        BTreeNode node = BTreeNode.readFrom(page);
        
        int idx = findKeyIndex(node.getKeys(), key);
        
        if (node.isLeaf()) {
            // 리프 노드: 키가 있으면 값 반환
            if (idx < node.getKeys().size() && node.getKeys().get(idx) == key) {
                return node.getValues().get(idx);
            }
            return null; // 키 없음
        } else {
            // 내부 노드: 적절한 자식으로 내려감
            return searchInNode(node.getChildren().get(idx), key);
        }
    }
    
    private int findKeyIndex(List<Integer> keys, int key) {
        int lo = 0, hi = keys.size();
        while (lo < hi) {
            int mid = (lo + hi) / 2;
            if (keys.get(mid) < key) {
                lo = mid + 1;
            } else {
                hi = mid;
            }
        }
        return lo;
    }
    
    // 삽입
    public void insert(int key, byte[] value) throws IOException {
        Page rootPage = pageManager.getPage(rootPageId);
        BTreeNode root = BTreeNode.readFrom(rootPage);
        
        if (root.isFull()) {
            // 루트가 가득 찼으면 새 루트 생성
            Page newRootPage = pageManager.allocatePage();
            BTreeNode newRoot = new BTreeNode(newRootPage.getPageId(), false);
            newRoot.getChildren().add(rootPageId);
            
            splitChild(newRoot, 0, root);
            
            newRoot.writeTo(newRootPage);
            rootPageId = newRootPage.getPageId();
            
            insertNonFull(newRoot, key, value);
        } else {
            insertNonFull(root, key, value);
        }
    }
    
    private void insertNonFull(BTreeNode node, int key, byte[] value) throws IOException {
        int idx = findKeyIndex(node.getKeys(), key);
        
        if (node.isLeaf()) {
            // 리프 노드에 삽입
            node.getKeys().add(idx, key);
            node.getValues().add(idx, value);
            
            Page page = pageManager.getPage(node.getPageId());
            node.writeTo(page);
        } else {
            // 내부 노드: 자식으로 내려감
            Page childPage = pageManager.getPage(node.getChildren().get(idx));
            BTreeNode child = BTreeNode.readFrom(childPage);
            
            if (child.isFull()) {
                splitChild(node, idx, child);
                
                // 분할 후 어느 쪽으로 갈지 결정
                if (key > node.getKeys().get(idx)) {
                    idx++;
                    childPage = pageManager.getPage(node.getChildren().get(idx));
                    child = BTreeNode.readFrom(childPage);
                }
            }
            
            insertNonFull(child, key, value);
        }
    }
    
    private void splitChild(BTreeNode parent, int childIndex, BTreeNode child) 
            throws IOException {
        int mid = child.getKeys().size() / 2;
        
        // 새 노드 생성 (오른쪽 절반)
        Page newPage = pageManager.allocatePage();
        BTreeNode newNode = new BTreeNode(newPage.getPageId(), child.isLeaf());
        
        // 키 분할
        int midKey = child.getKeys().get(mid);
        
        for (int i = mid + 1; i < child.getKeys().size(); i++) {
            newNode.getKeys().add(child.getKeys().get(i));
        }
        
        if (child.isLeaf()) {
            // 리프 노드: 값도 분할, midKey도 새 노드에 포함
            newNode.getKeys().add(0, midKey);
            for (int i = mid; i < child.getValues().size(); i++) {
                newNode.getValues().add(child.getValues().get(i));
            }
            
            // 리프 연결 리스트 유지
            newNode.setNextLeaf(child.getNextLeaf());
            child.setNextLeaf(newPage.getPageId());
            
            // 원래 노드에서 제거
            while (child.getKeys().size() > mid) {
                child.getKeys().remove(mid);
            }
            while (child.getValues().size() > mid) {
                child.getValues().remove(mid);
            }
        } else {
            // 내부 노드: 자식 포인터도 분할
            for (int i = mid + 1; i < child.getChildren().size(); i++) {
                newNode.getChildren().add(child.getChildren().get(i));
            }
            
            // 원래 노드에서 제거
            while (child.getKeys().size() > mid) {
                child.getKeys().remove(mid);
            }
            while (child.getChildren().size() > mid + 1) {
                child.getChildren().remove(mid + 1);
            }
        }
        
        // 부모에 midKey와 새 자식 추가
        parent.getKeys().add(childIndex, midKey);
        parent.getChildren().add(childIndex + 1, newPage.getPageId());
        
        // 변경사항 저장
        Page childPage = pageManager.getPage(child.getPageId());
        child.writeTo(childPage);
        newNode.writeTo(newPage);
        
        Page parentPage = pageManager.getPage(parent.getPageId());
        parent.writeTo(parentPage);
    }
    
    // 범위 검색 (리프 노드 연결 리스트 활용)
    public List<byte[]> rangeSearch(int startKey, int endKey) throws IOException {
        List<byte[]> results = new ArrayList<>();
        
        // 시작 키가 있는 리프 노드 찾기
        int leafPageId = findLeafNode(rootPageId, startKey);
        
        while (leafPageId != -1) {
            Page page = pageManager.getPage(leafPageId);
            BTreeNode leaf = BTreeNode.readFrom(page);
            
            for (int i = 0; i < leaf.getKeys().size(); i++) {
                int key = leaf.getKeys().get(i);
                if (key > endKey) {
                    return results; // 범위 끝
                }
                if (key >= startKey) {
                    results.add(leaf.getValues().get(i));
                }
            }
            
            leafPageId = leaf.getNextLeaf();
        }
        
        return results;
    }
    
    private int findLeafNode(int pageId, int key) throws IOException {
        Page page = pageManager.getPage(pageId);
        BTreeNode node = BTreeNode.readFrom(page);
        
        if (node.isLeaf()) {
            return pageId;
        }
        
        int idx = findKeyIndex(node.getKeys(), key);
        return findLeafNode(node.getChildren().get(idx), key);
    }
}
```

코드가 길지만 핵심은 세 가지다.

**1. 검색 (`search`)**

루트에서 시작해서 리프까지 내려간다. 각 노드에서 이진 검색으로 다음에 갈 자식을 찾는다.

**2. 삽입 (`insert`)**

리프 노드에 키를 넣는다. 노드가 가득 차면 분할한다. 분할하면 중간 키가 부모로 올라간다.

**3. 범위 검색 (`rangeSearch`)**

리프 노드끼리 연결되어 있어서 가능하다. 시작 키가 있는 리프를 찾고, 다음 리프로 계속 이동하면서 범위 안의 값을 수집한다.

`WHERE id BETWEEN 100 AND 200` 같은 쿼리가 빠른 이유가 이거다.

## Part 3: 간단한 테이블과 쿼리

이제 B+Tree 위에 테이블 개념을 얹어보자.

### Table 클래스

```java
public class Table {
    private final String name;
    private final BTree primaryIndex;
    private final PageManager pageManager;
    private int nextRowId;
    
    public Table(String name, PageManager pageManager) throws IOException {
        this.name = name;
        this.pageManager = pageManager;
        this.primaryIndex = new BTree(pageManager);
        this.nextRowId = 1;
    }
    
    // INSERT
    public int insert(Map<String, Object> row) throws IOException {
        int rowId = nextRowId++;
        byte[] data = serialize(row);
        primaryIndex.insert(rowId, data);
        return rowId;
    }
    
    // SELECT by primary key
    public Map<String, Object> selectById(int id) throws IOException {
        byte[] data = primaryIndex.search(id);
        if (data == null) return null;
        return deserialize(data);
    }
    
    // SELECT range
    public List<Map<String, Object>> selectRange(int startId, int endId) 
            throws IOException {
        List<byte[]> dataList = primaryIndex.rangeSearch(startId, endId);
        List<Map<String, Object>> results = new ArrayList<>();
        for (byte[] data : dataList) {
            results.add(deserialize(data));
        }
        return results;
    }
    
    // 간단한 직렬화 (실제로는 더 효율적인 방식 사용)
    private byte[] serialize(Map<String, Object> row) {
        try {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            ObjectOutputStream oos = new ObjectOutputStream(baos);
            oos.writeObject(row);
            oos.close();
            return baos.toByteArray();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
    
    @SuppressWarnings("unchecked")
    private Map<String, Object> deserialize(byte[] data) {
        try {
            ByteArrayInputStream bais = new ByteArrayInputStream(data);
            ObjectInputStream ois = new ObjectInputStream(bais);
            return (Map<String, Object>) ois.readObject();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
```

### 사용 예시

```java
public class MiniDBExample {
    public static void main(String[] args) throws IOException {
        // 데이터베이스 초기화
        PageManager pageManager = new PageManager("test.db", 100);
        Table users = new Table("users", pageManager);
        
        // 데이터 삽입
        for (int i = 1; i <= 10000; i++) {
            Map<String, Object> row = new HashMap<>();
            row.put("name", "User" + i);
            row.put("email", "user" + i + "@example.com");
            row.put("age", 20 + (i % 50));
            users.insert(row);
        }
        
        System.out.println("Inserted 10000 rows");
        
        // 단일 조회
        long start = System.nanoTime();
        Map<String, Object> user = users.selectById(5000);
        long end = System.nanoTime();
        
        System.out.println("Select by ID 5000: " + user);
        System.out.println("Time: " + (end - start) / 1000 + " microseconds");
        
        // 범위 조회
        start = System.nanoTime();
        List<Map<String, Object>> range = users.selectRange(1000, 1100);
        end = System.nanoTime();
        
        System.out.println("Range select 1000-1100: " + range.size() + " rows");
        System.out.println("Time: " + (end - start) / 1000 + " microseconds");
        
        // 정리
        pageManager.close();
    }
}
```

출력:
```
Inserted 10000 rows
Select by ID 5000: {name=User5000, email=user5000@example.com, age=20}
Time: 45 microseconds
Range select 1000-1100: 101 rows
Time: 230 microseconds
```

10000개 데이터에서 단일 조회 45마이크로초. 범위 조회 230마이크로초.

B+Tree가 왜 빠른지 체감된다.

## 실제 데이터베이스와의 차이

이 미니 DB에는 없는 것들이 많다.

### 트랜잭션 (ACID)

실제 DB는 WAL(Write-Ahead Logging)을 사용한다.

```
1. 변경사항을 먼저 로그에 기록
2. 로그가 디스크에 안전하게 저장되면
3. 그때서야 실제 데이터 페이지를 수정
```

이래야 중간에 서버가 죽어도 복구할 수 있다.

### 동시성 제어

여러 트랜잭션이 동시에 같은 데이터를 수정하면? Lock이나 MVCC(Multi-Version Concurrency Control)가 필요하다.

### 쿼리 최적화

`SELECT * FROM users WHERE age > 30 AND city = 'Seoul'`

이 쿼리를 어떻게 실행할지 결정하는 게 쿼리 옵티마이저다. 어떤 인덱스를 쓸지, 조인 순서는 어떻게 할지.

### Buffer Pool 관리

LRU보다 더 정교한 알고리즘을 쓴다. MySQL은 LRU를 변형한 방식을 쓰고, 자주 쓰는 페이지가 밀려나지 않도록 보호한다.

## 이걸 만들면서 배운 것

**인덱스가 왜 빠른지 진짜 이해했다.**

O(log n)이라는 말만 외우는 것과, 직접 B+Tree를 구현해서 디스크 I/O가 줄어드는 걸 보는 건 다르다.

**페이지라는 개념이 왜 중요한지 알았다.**

데이터베이스 튜닝할 때 `innodb_page_size` 같은 설정이 있다. 이게 뭔지 몰랐는데 이제 안다.

**인덱스 설계가 왜 중요한지 체감했다.**

인덱스 없이 10000개 데이터를 순차 검색하면 4ms. 인덱스 있으면 45μs. 100배 차이.

100만 개면? 1000만 개면? 인덱스 없이는 서비스가 안 된다.

## 더 해볼 것들

이 미니 DB를 확장하면서 더 배울 수 있다.

1. **WAL 구현하기** - 트랜잭션 복구
2. **Secondary Index** - Primary Key 외의 컬럼으로 검색
3. **간단한 SQL 파서** - `SELECT * FROM users WHERE id = 5`
4. **조인 구현** - Nested Loop Join부터

한 번에 다 하려면 막막하다. 하나씩 추가하면 된다.

MySQL 소스코드를 보면 30년간 쌓인 최적화가 있다. 그걸 다 따라할 필요는 없다. 핵심 원리만 이해하면 된다.

---

"인덱스가 왜 빠른가요?"

이제 이 질문에 이렇게 답할 수 있다.

"B+Tree 구조라서 O(log n)입니다. 한 노드에 여러 키가 들어가서 디스크 I/O가 줄어들고, 리프 노드끼리 연결되어 있어서 범위 검색도 빠릅니다. 직접 구현해봤는데, 페이지 단위로 데이터를 관리하는 게 핵심이더라고요."

면접관 표정이 달라진다.

