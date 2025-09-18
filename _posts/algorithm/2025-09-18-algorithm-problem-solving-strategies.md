---
title: "알고리즘 문제 해결 전략"
date: 2025-09-18
categories: Algorithm
tags: [algorithm, coding-test, problem-solving, data-structure, java]
author: pitbull terrier
---

# 알고리즘 문제 해결 전략: 코딩테스트 완전 정복하기

알고리즘 문제를 처음 봤을 때는 정말 막막했다. 문제를 읽어도 무슨 말인지 모르겠고, 코드를 어떻게 짜야 할지도 감이 안 왔다. 하지만 체계적으로 접근하니까 점점 풀 수 있는 문제가 늘어났다.

## 왜 알고리즘을 공부해야 할까?

개발자라면 알고리즘을 피할 수 없다. 코딩테스트에서도 나오고, 실제 개발에서도 성능을 고려할 때 필수다. 

더 중요한 건 사고력이다. 복잡한 문제를 작은 단위로 나누고, 논리적으로 접근하는 능력이 생긴다. 이건 개발뿐만 아니라 일상생활에서도 도움이 된다.

## 문제 해결 접근법

### 1단계: 문제 이해하기

문제를 제대로 이해하지 못하면 절대 풀 수 없다. 다음 순서로 접근하자.

1. **문제를 여러 번 읽어보기**
2. **예시 입력/출력 분석하기**
3. **제약 조건 확인하기**
4. **자신만의 말로 다시 설명하기**

예를 들어 이런 문제가 있다고 하자.

> 정수 배열이 주어졌을 때, 두 수를 더해서 특정 값이 되는 인덱스를 찾아라.

이 문제를 분석해보면:
- 입력: 정수 배열, 목표 값
- 출력: 두 인덱스 (배열)
- 제약: 정확히 하나의 해가 존재한다고 가정

### 2단계: 접근 방법 생각하기

문제를 이해했으면 어떻게 풀지 생각해보자. 여러 방법이 있을 수 있다.

**브루트 포스 (완전 탐색)**
- 모든 경우의 수를 다 확인하는 방법
- 시간복잡도가 높지만 확실하다
- 작은 데이터에서는 충분히 빠르다

**정렬 후 투 포인터**
- 배열을 정렬한 후 양 끝에서 시작
- 시간복잡도 O(n log n)
- 메모리 효율적

**해시맵 사용**
- 한 번의 순회로 해결
- 시간복잡도 O(n)
- 메모리를 더 사용한다

### 3단계: 코드 작성하기

접근 방법을 정했으면 코드를 작성하자. 이때 주의할 점들:

1. **변수명을 명확하게**
2. **주석을 적절히 달기**
3. **예외 상황 고려하기**
4. **코드가 읽기 쉽게**

## 기본 자료구조 활용

### 배열 (Array)

가장 기본적인 자료구조다. 인덱스로 접근할 수 있어서 빠르다.

```java
public class ArrayExample {
    public static void main(String[] args) {
        int[] arr = {1, 2, 3, 4, 5};
        
        // 배열 순회
        for (int i = 0; i < arr.length; i++) {
            System.out.println(arr[i]);
        }
        
        // 향상된 for문
        for (int num : arr) {
            System.out.println(num);
        }
    }
}
```

**배열의 장점:**
- 인덱스로 O(1) 접근
- 메모리 효율적
- 캐시 지역성 좋음

**배열의 단점:**
- 크기 고정
- 삽입/삭제 비효율적

### 리스트 (List)

동적 크기를 가진 자료구조다. Java에서는 ArrayList가 대표적이다.

```java
import java.util.ArrayList;
import java.util.List;

public class ListExample {
    public static void main(String[] args) {
        List<Integer> list = new ArrayList<>();
        
        // 요소 추가
        list.add(1);
        list.add(2);
        list.add(3);
        
        // 요소 접근
        System.out.println(list.get(0)); // 1
        
        // 요소 삭제
        list.remove(1); // 인덱스 1의 요소 삭제
        
        // 크기 확인
        System.out.println(list.size()); // 2
    }
}
```

### 스택 (Stack)

LIFO(Last In, First Out) 구조다. 재귀를 반복문으로 바꿀 때 유용하다.

```java
import java.util.Stack;

public class StackExample {
    public static void main(String[] args) {
        Stack<Integer> stack = new Stack<>();
        
        // 요소 추가
        stack.push(1);
        stack.push(2);
        stack.push(3);
        
        // 요소 확인 (제거하지 않음)
        System.out.println(stack.peek()); // 3
        
        // 요소 제거
        System.out.println(stack.pop()); // 3
        System.out.println(stack.pop()); // 2
        
        // 비어있는지 확인
        System.out.println(stack.isEmpty()); // false
    }
}
```

### 큐 (Queue)

FIFO(First In, First Out) 구조다. BFS에서 자주 사용한다.

```java
import java.util.LinkedList;
import java.util.Queue;

public class QueueExample {
    public static void main(String[] args) {
        Queue<Integer> queue = new LinkedList<>();
        
        // 요소 추가
        queue.offer(1);
        queue.offer(2);
        queue.offer(3);
        
        // 요소 확인 (제거하지 않음)
        System.out.println(queue.peek()); // 1
        
        // 요소 제거
        System.out.println(queue.poll()); // 1
        System.out.println(queue.poll()); // 2
        
        // 비어있는지 확인
        System.out.println(queue.isEmpty()); // false
    }
}
```

### 해시맵 (HashMap)

키-값 쌍을 저장하는 자료구조다. 빠른 검색이 필요할 때 사용한다.

```java
import java.util.HashMap;
import java.util.Map;

public class HashMapExample {
    public static void main(String[] args) {
        Map<String, Integer> map = new HashMap<>();
        
        // 키-값 추가
        map.put("apple", 100);
        map.put("banana", 200);
        map.put("orange", 150);
        
        // 값 조회
        System.out.println(map.get("apple")); // 100
        
        // 키 존재 확인
        System.out.println(map.containsKey("grape")); // false
        
        // 모든 키-값 순회
        for (Map.Entry<String, Integer> entry : map.entrySet()) {
            System.out.println(entry.getKey() + ": " + entry.getValue());
        }
    }
}
```

## 자주 나오는 문제 유형

### 1. 두 수의 합 (Two Sum)

가장 기본적인 문제다. 여러 방법으로 풀 수 있다.

**문제:** 정수 배열과 목표 값이 주어졌을 때, 두 수의 합이 목표 값이 되는 인덱스를 찾아라.

**브루트 포스 방법:**
```java
public int[] twoSum(int[] nums, int target) {
    for (int i = 0; i < nums.length; i++) {
        for (int j = i + 1; j < nums.length; j++) {
            if (nums[i] + nums[j] == target) {
                return new int[]{i, j};
            }
        }
    }
    return new int[0]; // 해가 없는 경우
}
```

**해시맵 방법:**
```java
public int[] twoSum(int[] nums, int target) {
    Map<Integer, Integer> map = new HashMap<>();
    
    for (int i = 0; i < nums.length; i++) {
        int complement = target - nums[i];
        if (map.containsKey(complement)) {
            return new int[]{map.get(complement), i};
        }
        map.put(nums[i], i);
    }
    return new int[0];
}
```

### 2. 최대 부분 배열 합 (Maximum Subarray)

동적 프로그래밍의 대표적인 문제다.

**문제:** 정수 배열에서 연속된 부분 배열의 최대 합을 구해라.

**Kadane's Algorithm:**
```java
public int maxSubArray(int[] nums) {
    int maxSoFar = nums[0];
    int maxEndingHere = nums[0];
    
    for (int i = 1; i < nums.length; i++) {
        maxEndingHere = Math.max(nums[i], maxEndingHere + nums[i]);
        maxSoFar = Math.max(maxSoFar, maxEndingHere);
    }
    
    return maxSoFar;
}
```

### 3. 이진 탐색 (Binary Search)

정렬된 배열에서 특정 값을 찾는 효율적인 방법이다.

**문제:** 정렬된 배열에서 특정 값의 인덱스를 찾아라.

```java
public int binarySearch(int[] nums, int target) {
    int left = 0;
    int right = nums.length - 1;
    
    while (left <= right) {
        int mid = left + (right - left) / 2;
        
        if (nums[mid] == target) {
            return mid;
        } else if (nums[mid] < target) {
            left = mid + 1;
        } else {
            right = mid - 1;
        }
    }
    
    return -1; // 찾지 못한 경우
}
```

### 4. 연결 리스트 뒤집기 (Reverse Linked List)

연결 리스트의 기본 연산이다.

**문제:** 연결 리스트를 뒤집어라.

```java
public ListNode reverseList(ListNode head) {
    ListNode prev = null;
    ListNode current = head;
    
    while (current != null) {
        ListNode next = current.next;
        current.next = prev;
        prev = current;
        current = next;
    }
    
    return prev;
}
```

## 정렬 알고리즘

### 버블 정렬 (Bubble Sort)

가장 간단하지만 비효율적인 정렬이다.

```java
public void bubbleSort(int[] arr) {
    int n = arr.length;
    
    for (int i = 0; i < n - 1; i++) {
        for (int j = 0; j < n - i - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                // 스왑
                int temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
            }
        }
    }
}
```

### 선택 정렬 (Selection Sort)

매번 최솟값을 찾아서 앞으로 보내는 정렬이다.

```java
public void selectionSort(int[] arr) {
    int n = arr.length;
    
    for (int i = 0; i < n - 1; i++) {
        int minIdx = i;
        
        for (int j = i + 1; j < n; j++) {
            if (arr[j] < arr[minIdx]) {
                minIdx = j;
            }
        }
        
        // 스왑
        int temp = arr[i];
        arr[i] = arr[minIdx];
        arr[minIdx] = temp;
    }
}
```

### 퀵 정렬 (Quick Sort)

분할 정복을 사용하는 효율적인 정렬이다.

```java
public void quickSort(int[] arr, int low, int high) {
    if (low < high) {
        int pivotIndex = partition(arr, low, high);
        quickSort(arr, low, pivotIndex - 1);
        quickSort(arr, pivotIndex + 1, high);
    }
}

private int partition(int[] arr, int low, int high) {
    int pivot = arr[high];
    int i = low - 1;
    
    for (int j = low; j < high; j++) {
        if (arr[j] <= pivot) {
            i++;
            swap(arr, i, j);
        }
    }
    
    swap(arr, i + 1, high);
    return i + 1;
}

private void swap(int[] arr, int i, int j) {
    int temp = arr[i];
    arr[i] = arr[j];
    arr[j] = temp;
}
```

## 그래프 알고리즘

### 깊이 우선 탐색 (DFS)

재귀나 스택을 사용해서 깊이 우선으로 탐색한다.

```java
public void dfs(int[][] graph, int start, boolean[] visited) {
    visited[start] = true;
    System.out.print(start + " ");
    
    for (int neighbor : graph[start]) {
        if (!visited[neighbor]) {
            dfs(graph, neighbor, visited);
        }
    }
}
```

### 너비 우선 탐색 (BFS)

큐를 사용해서 너비 우선으로 탐색한다.

```java
import java.util.LinkedList;
import java.util.Queue;

public void bfs(int[][] graph, int start, boolean[] visited) {
    Queue<Integer> queue = new LinkedList<>();
    queue.offer(start);
    visited[start] = true;
    
    while (!queue.isEmpty()) {
        int current = queue.poll();
        System.out.print(current + " ");
        
        for (int neighbor : graph[current]) {
            if (!visited[neighbor]) {
                visited[neighbor] = true;
                queue.offer(neighbor);
            }
        }
    }
}
```

## 실전 팁

### 1. 시간복잡도 고려하기

문제를 풀기 전에 시간복잡도를 고려하자.

- **O(1)**: 상수 시간
- **O(log n)**: 로그 시간 (이진 탐색)
- **O(n)**: 선형 시간 (한 번 순회)
- **O(n log n)**: 정렬 시간
- **O(n²)**: 이중 반복문
- **O(2ⁿ)**: 지수 시간 (피보나치 재귀)

### 2. 공간복잡도 고려하기

메모리 사용량도 고려해야 한다.

- **O(1)**: 상수 공간
- **O(n)**: 선형 공간 (배열, 리스트)
- **O(n²)**: 2차원 배열

### 3. 예외 상황 처리하기

코딩테스트에서 예외 상황을 놓치면 틀린다.

- **빈 배열**
- **단일 요소**
- **모든 요소가 같은 경우**
- **경계값**

### 4. 테스트 케이스 만들기

자신만의 테스트 케이스를 만들어보자.

```java
public static void main(String[] args) {
    // 정상 케이스
    int[] nums1 = {2, 7, 11, 15};
    int target1 = 9;
    System.out.println(Arrays.toString(twoSum(nums1, target1))); // [0, 1]
    
    // 예외 케이스
    int[] nums2 = {3, 3};
    int target2 = 6;
    System.out.println(Arrays.toString(twoSum(nums2, target2))); // [0, 1]
    
    // 해가 없는 경우
    int[] nums3 = {1, 2, 3};
    int target3 = 7;
    System.out.println(Arrays.toString(twoSum(nums3, target3))); // []
}
```

## 연습 방법

### 1. 단계별 접근

- **1단계**: 기본 문제부터 시작
- **2단계**: 자료구조별 문제 풀기
- **3단계**: 알고리즘별 문제 풀기
- **4단계**: 복합 문제 도전

### 2. 패턴 익히기

비슷한 문제들은 비슷한 패턴을 가진다.

- **투 포인터**: 정렬된 배열에서 두 값의 합
- **슬라이딩 윈도우**: 연속된 부분 배열
- **해시맵**: 빠른 검색이 필요한 경우
- **스택**: 괄호 문제, 히스토리 관리

### 3. 복습하기

한 번 풀었다고 끝이 아니다. 나중에 다시 풀어보자.

- **1주일 후**: 기억이 생생할 때
- **1개월 후**: 완전히 잊었을 때
- **3개월 후**: 진짜 내 것이 되었는지 확인

## 결론

알고리즘 문제 해결은 하루아침에 늘지 않는다. 꾸준한 연습이 필요하다. 하지만 체계적으로 접근하면 분명히 실력이 늘 것이다.

처음에는 어려워도 포기하지 말자. 한 문제씩 풀어가다 보면 어느새 코딩테스트도 통과하고, 실제 개발에서도 더 효율적인 코드를 짤 수 있게 된다.
