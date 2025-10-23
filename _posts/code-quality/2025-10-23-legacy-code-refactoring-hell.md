---
title: "10년 된 300줄짜리 함수 뜯어보기"
tags: refactoring legacy-code code-quality javascript clean-code
date: "2025.10.23"
categories:
    - Code-Quality
---

## 실제 운영 중인 코드다

회사 레거시 시스템 코드 중 일부다. 10년 넘게 돌아가고 있다.


```javascript
function fn_Select(mrgData,pagingType) {
	var reqType,
	    //recType,
	    reqQty,
	    lep,
	    ptno,
	    vndM,
	    vndS,
	    //rucCd,
	    procTy,
	    pageNo,
	    rcnt,
	    depCd,
	    i;
	
	/*if(fn_IsEmpty(mrgData)){
		pageNo = 1;
	}*/
		
	//청구번호 설정
	if(!fn_IsEmpty(text_DMDREMARK.getValue())){
	    
	    //2014.10.30 : 청구번호 중복체크
	    var tmpDmdnoArr = text_DMDREMARK.getValue().replaceAll(" ", "").split(",");
		var dmdnoArr = arrayDuplicate(tmpDmdnoArr);
		text_DMDREMARK.setValue( dmdnoArr );
			    
		var v_dmdno = text_DMDREMARK.getValue().replace(/,/gi,"</A></H><H><A>");
			v_dmdno = "<dataset><H><A>"+v_dmdno+"</A></H></dataset>";
		
		fn_SaveDMD(v_dmdno);
		
		return false;
	}
		
	FV_TIMESTAMP = '';
		
	//페이징 파라미터 설정
	if(fn_IsEmpty(mrgData)){
		mrgData = ''; 
	}
	
	//페이징 파라미터 설정2
	if(fn_IsEmpty(pagingType)){
		pagingType = 'C'; 
	}
	
	//청구유형
	if(fn_IsEmpty(sele_REQ_TYPE.getValue())){
		reqType = '-999'; 
	}else{
		reqType = sele_REQ_TYPE.getValue();
	}
	
	//품목유형 설정
	if(fn_IsEmpty(auto_S_DEPCD.getValue())){
		depCd = '-999'; 
	}else{
		depCd = auto_S_DEPCD.getValue();
	}
	
	//배송구분 설정
	/*if(fn_IsEmpty(sele_REC_TYPE.getValue())){
		recType = '-999'; 
	}else{
		recType = sele_REC_TYPE.getValue();
	}*/
	
	//배송노선 설정
	/*if(fn_IsEmpty(sele_SCD_RUTCD.getValue())){
		rucCd = '-999'; 
	}else{
		rucCd = sele_SCD_RUTCD.getValue();
	}*/
	
	//가용재고
	if(fn_IsEmpty(sele_REQQTY.getValue())){
		reqQty = '-999'; 
	}else{
		reqQty = sele_REQQTY.getValue();
	}
	
	//LEP 설정
	if(fn_IsEmpty(sele_RSV_LEP.getValue())){
		lep = '-999'; 
	}else{
		lep = sele_RSV_LEP.getValue();
	}
	
	//부품번호 설정
	if(fn_IsEmpty(inpu_RSV_PTNO.getValue())){
		ptno = '-999'; 
	}else{
		ptno = inpu_RSV_PTNO.getValue();
	}
	
	//거래처 메인 설정
	if(fn_IsEmpty(auto_VNDCD_MN.getValue())){
		vndM = '-999'; 
	}else{
		vndM = auto_VNDCD_MN.getValue();
	}
	
	//거래처 서브 설정
	if(fn_IsEmpty(auto_VNDCD_SB.getValue())){
		vndS = '-999'; 
	}else{
		vndS = auto_VNDCD_SB.getValue();
	}
	
	//최종조치 설정
	if(fn_IsEmpty(sele_PROCTY.getValue())){
		procTy = '-999'; 
	}else{
		procTy = sele_PROCTY.getValue();
	}
		
	if(inpu_REQDT_FIRST.getValue().trim().length != 8 ||inpu_REQDT_LAST.getValue().trim().length != 8){
		alert("대상기간을 확인바랍니다.");
		return false;
	}
	
	var regDate = '^(19[0-9]{2}|2[0-9]{3})(0[1-9]{1}|1[0-2]{1}){1}(0[1-9]|(1|2)[0-9]|3[0-1]){1}$'; 
	var dt1= inpu_REQDT_FIRST.getValue(); 
	var dt2= inpu_REQDT_LAST.getValue(); 
	
	if(!dt1.match(regDate)) { 
		alert("대상기간을 확인바랍니다.");
		return false; 
	}
	
	if(!dt2.match(regDate)) { 
		alert("대상기간을 확인바랍니다.");
		return false; 
	}
	
	//2014.08.12 추가
	if(inpu_REQDT_FIRST.getValue() > inpu_REQDT_LAST.getValue()){
		alert("청구일자 시작일이 종료일보다 클 수 없습니다.");
		return false;
	}
	
	//조회기간이 31을 넘기면 안됨!
	if((getDayInterval( inpu_REQDT_FIRST.getValue() , inpu_REQDT_LAST.getValue() )) > 31){
		alert("대상기간은 31일을 넘길 수 없습니다.");
		return false;
	}
	
	//2014.12.05 SQL 튜닝으로 인한 처리
	var usrAgtcdH = hidden_USR_AGTCD_H.getValue();
	if(fn_IsEmpty(usrAgtcdH)){
		usrAgtcdH = "";
	}
	
	var usrAgtcdK = hidden_USR_AGTCD_K.getValue();
	if(fn_IsEmpty(usrAgtcdK)){
		usrAgtcdK = "";
	}
	
	
	// 그리드 초기화
    grid1.removeAll();
	
	// 엑션 정보 생성
	tit_ClearActionInfo();

	// 조회 쿼리 추가
	if(pagingType == 'B'){
		tit_AddSearchActionInfo("collect:HT09_W01_S01");
	
	}else{
		tit_AddSearchActionInfo("collect:HT09_W01_S05");
	  
	  	//최초 조회 시에만 Summary 정보를 조회한다.
	  	if(pagingType == 'C'){
	  		tit_AddSearchActionInfo("collect:HT09_W01_S06");
	  	}
	}
	
	// 파라미터 추가
	tit_AddInputParamData("AGTCD",  		FV_AGTCD);
	tit_AddInputParamData("FR_DT",  		inpu_REQDT_FIRST.getValue());
	tit_AddInputParamData("TO_DT",  		inpu_REQDT_LAST.getValue());
	tit_AddInputParamData("IRN_DMD_TYPE",  	reqType);
	tit_AddInputParamData("INV_AVLQT",  	reqQty);
	tit_AddInputParamData("LEP",  			lep);
	tit_AddInputParamData("PTNO",  			ptno);
	tit_AddInputParamData("VEN_M",  		vndM);
	tit_AddInputParamData("VEN_S",  		vndS);
	tit_AddInputParamData("FINAL_STAT",  	procTy);
	tit_AddInputParamData("DEPCD",  		depCd);
	tit_AddInputParamData("MERGEVALUE",  	mrgData);
	tit_AddInputParamData("PAGING_TYPE", 	pagingType);
	tit_AddInputParamData("USR_AGTCD_H", usrAgtcdH);
	tit_AddInputParamData("USR_AGTCD_K", usrAgtcdK);
	
	//2015.08.27 RONO추가
	var strRONo = "";
	
	if(trim(inpu_RONO.getValue()) != ""){ 
		strRONo = "%" + trim(inpu_RONO.getValue()) + "%";
	}
	
	tit_AddInputParamData("RONO", strRONo);
	
	//2020.02.07 REMARK추가
	var strREMARK = "";
	
	if(trim(text_TRFREMARK.getValue()) != ""){ 
		strREMARK = "%" + trim(text_TRFREMARK.getValue()) + "%";
	}
	
	tit_AddInputParamData("REMARK", strREMARK);

	// 서버콜
	tit_CallService("HAIMS_COLL_ACTION", "", "fn_AfterSelect");
}

function fn_AfterSelect() {
	if(gfn_isTransactionSuccess(tit_GetErrorLog("CODE", "res"))){
		
		var i,rcount,initLeng,difLeng;

		grid1.setXML(WebSquare.ModelUtil.findInstanceNode("res/root/dataset[@id='dsOutHT09_W01_S01']"));
		
		irnDmdType = WebSquare.ModelUtil.getInstanceValue("res/root/dataset[@id='dsOutHT09_W01_S01']/record/IRN_DMD_TYPE");
		
		console.log("irnDmdType : ", irnDmdType);
		
		grid1.checkAll(grid1.getColumnIndex("CHK"), '1');
		grid1.setHeaderValue("head_CHK", true);
		
		rcount = grid1.getRowCount(); 
		
		var totalCount = 0;
		
		for(i=0; i < rcount; i++){
			if(Number(grid1.getCellData( i , "PROC_QTY" )) > Number(grid1.getCellData( i , "INV_AVLQT" ))){
				grid1.setCellColor( i , "PROC_QTY" 	  , 'red' );
			}else{
				grid1.setCellColor( i , "PROC_QTY" 	  , 'black' );
			}
			
			if(Number(grid1.getCellData( i , "WSN_SALECST" )) > 0 && Number(grid1.getCellData( i , "WSN_SALECST" )) !== Number(grid1.getCellData( i , "SALE_PRC" ))){
				grid1.setCellColor( i , "WSN_SALECST" 	  , 'red' );
			}else{
				grid1.setCellColor( i , "WSN_SALECST" 	  , 'black' );
			}
			
			//경찰청이나 육군본부인 경우 판매단가 수정불가 처리
			if(grid1.getCellData( i , "IRN_AG_USRTY" ) === "P" || grid1.getCellData( i , "IRN_AG_USRTY" ) === "O"){
				grid1.setCellReadOnly( i ,"SALE_PRC" , true);
			}
			//최종조치가 판매완료인 경우 수정불가 처리
			if(grid1.getCellData( i , "FINAL_STAT" ) === "판매완료"){
				grid1.setCellReadOnly( i ,"IRN_LEP" , true);
				grid1.setCellReadOnly( i ,"IRN_PTNO" , true);
				grid1.setCellReadOnly( i ,"WHSCD" , true);
				grid1.setCellReadOnly( i ,"IRN_DMD_QTY" , true);
				grid1.setCellReadOnly( i ,"PROC_QTY" , true);
				grid1.setCellReadOnly( i ,"SALE_PRC" , true);
				grid1.setCellReadOnly( i ,"SPEC_YN" , true);
			} 
			
			//KSW유리청구건만 조치예정일 수정가능
			if(Number(grid1.getCellData( i , "SHP_CNT" )) == 0 ){
				grid1.setCellReadOnly( i ,"IRN_APR_DATE" , true);
				grid1.setCellBackgroundColor( i , "IRN_APR_DATE", 'gray' );
			}
		}
		
		inpu_TOTCNT.setValue(WebSquare.ModelUtil.getInstanceValue("res/root/dataset[@id='dsOutHT09_W01_SUMMARY']/record/TOTCNT"));
		
		fn_ExcelB_Ctrl();
		
		if(rcount > 0){
			trig_Save.setDisabled(false);
			trigger18.setDisabled(false);
			trigger191.setDisabled(false);
		}else{
			trig_Save.setDisabled(true);
			trigger18.setDisabled(true);
			trigger191.setDisabled(true);
		}
		
		text_TRFREMARK.setValue('');
	}else{
		alert('일치하는 데이터가 없습니다.');
	}
}
```

300줄이 넘는다. 한 함수에서 모든 걸 처리한다.

<br>

## 문제점 1: 변수 선언이 뒤죽박죽

```javascript
var reqType,
    //recType,
    reqQty,
    lep,
    ptno,
    vndM,
    vndS,
    //rucCd,
    procTy,
    pageNo,
    rcnt,
    depCd,
    i;
```

변수 13개를 맨 위에 한 번에 선언했다. 주석 처리된 것도 섞여있다.

실제로 사용하는 곳은 100줄 아래다. 스크롤 올려서 확인해야 한다.

```javascript
function fn_Select(mrgData, pagingType) {
	// ... 100줄 생략 ...
	
	if(fn_IsEmpty(sele_REQ_TYPE.getValue())){
		reqType = '-999';  // reqType이 뭐였지? 스크롤 올림
	}
}
```

사용하는 곳에서 선언한다.

```javascript
function fn_Select(mrgData, pagingType) {
	var reqType = fn_IsEmpty(sele_REQ_TYPE.getValue()) ? '-999' : sele_REQ_TYPE.getValue();
}
```

<br>

## 문제점 2: 매직 넘버와 매직 스트링

```javascript
if(fn_IsEmpty(sele_REQ_TYPE.getValue())){
	reqType = '-999'; 
}else{
	reqType = sele_REQ_TYPE.getValue();
}
```

`'-999'`가 뭔가? 빈 값인가? NULL인가?

코드 전체에 `-999`, `'C'`, `'B'`, `'P'`, `'O'` 같은 값이 하드코딩돼 있다.

```javascript
var EMPTY_VALUE = '-999';
var PAGING_TYPE_INITIAL = 'C';
var PAGING_TYPE_BACK = 'B';
var USER_TYPE_POLICE = 'P';
var USER_TYPE_ARMY = 'O';

if(fn_IsEmpty(sele_REQ_TYPE.getValue())){
	requestType = EMPTY_VALUE; 
}else{
	requestType = sele_REQ_TYPE.getValue();
}
```

상수로 빼낸다. 의미가 명확하다.

<br>

## 문제점 3: 같은 패턴 10번 반복

```javascript
if(fn_IsEmpty(sele_REQ_TYPE.getValue())){
	reqType = '-999'; 
}else{
	reqType = sele_REQ_TYPE.getValue();
}

if(fn_IsEmpty(auto_S_DEPCD.getValue())){
	depCd = '-999'; 
}else{
	depCd = auto_S_DEPCD.getValue();
}

if(fn_IsEmpty(sele_REQQTY.getValue())){
	reqQty = '-999'; 
}else{
	reqQty = sele_REQQTY.getValue();
}
```

똑같은 패턴 10번 반복이다.

함수 하나로 끝난다.

```javascript
function getValueOrDefault(component, defaultValue) {
	return fn_IsEmpty(component.getValue()) ? defaultValue : component.getValue();
}

var requestType = getValueOrDefault(sele_REQ_TYPE, EMPTY_VALUE);
var departmentCode = getValueOrDefault(auto_S_DEPCD, EMPTY_VALUE);
var requestQuantity = getValueOrDefault(sele_REQQTY, EMPTY_VALUE);
```

<br>

## 문제점 4: 주석 처리된 코드가 산재

```javascript
/*if(fn_IsEmpty(mrgData)){
	pageNo = 1;
}*/

//배송구분 설정
/*if(fn_IsEmpty(sele_REC_TYPE.getValue())){
	recType = '-999'; 
}else{
	recType = sele_REC_TYPE.getValue();
}*/
```

그냥 지운다.

"나중에 필요할지도"라고 생각하지만, Git이 있다. 히스토리에 다 남는다.

주석 처리된 코드는 노이즈다. 코드 읽을 때 집중력만 떨어뜨린다.

<br>

## 문제점 5: 날짜 검증이 중복

```javascript
if(inpu_REQDT_FIRST.getValue().trim().length != 8 ||inpu_REQDT_LAST.getValue().trim().length != 8){
	alert("대상기간을 확인바랍니다.");
	return false;
}

var regDate = '^(19[0-9]{2}|2[0-9]{3})(0[1-9]{1}|1[0-2]{1}){1}(0[1-9]|(1|2)[0-9]|3[0-1]){1}$'; 
var dt1= inpu_REQDT_FIRST.getValue(); 
var dt2= inpu_REQDT_LAST.getValue(); 

if(!dt1.match(regDate)) { 
	alert("대상기간을 확인바랍니다.");
	return false; 
}

if(!dt2.match(regDate)) { 
	alert("대상기간을 확인바랍니다.");
	return false; 
}
```

"대상기간을 확인바랍니다" 메시지가 3번 나온다. 

정확히 뭐가 문제인지 알 수 없다. 8자리가 아닌가? 형식이 틀린가? 둘 다인가?

```javascript
function validateDate(dateValue, fieldName) {
	if (!dateValue || dateValue.trim().length !== 8) {
		alert(fieldName + "의 형식이 올바르지 않습니다. (YYYYMMDD)");
		return false;
	}
	
	var datePattern = /^(19[0-9]{2}|2[0-9]{3})(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])$/;
	if (!dateValue.match(datePattern)) {
		alert(fieldName + "이 유효한 날짜가 아닙니다.");
		return false;
	}
	
	return true;
}

var startDate = inpu_REQDT_FIRST.getValue();
var endDate = inpu_REQDT_LAST.getValue();

if (!validateDate(startDate, "시작일")) return false;
if (!validateDate(endDate, "종료일")) return false;

if (startDate > endDate) {
	alert("시작일이 종료일보다 클 수 없습니다.");
	return false;
}
```

에러 메시지가 구체적이다. "시작일의 형식이 올바르지 않습니다" vs "대상기간을 확인바랍니다"

<br>

## 문제점 6: 거대한 함수

`fn_Select` 함수가 300줄이다. 스크롤을 계속 내려야 한다.

이 함수가 하는 일:
1. 청구번호 처리
2. 파라미터 기본값 설정
3. 날짜 검증
4. 그리드 초기화
5. 쿼리 설정
6. 서버 호출

한 함수가 너무 많은 일을 한다.

```javascript
function fn_Select(mrgData, pagingType) {
	if (!validateDemandNumber()) return false;
	
	var params = buildSearchParameters(mrgData, pagingType);
	
	if (!validateSearchDates(params.startDate, params.endDate)) return false;
	
	executeSearch(params);
}

function validateDemandNumber() {
	if (fn_IsEmpty(text_DMDREMARK.getValue())) {
		return true;
	}
	
	var demandNumbers = text_DMDREMARK.getValue().replaceAll(" ", "").split(",");
	var uniqueDemandNumbers = arrayDuplicate(demandNumbers);
	text_DMDREMARK.setValue(uniqueDemandNumbers);
	
	var xmlData = buildDemandNumberXML(uniqueDemandNumbers);
	fn_SaveDMD(xmlData);
	
	return false;
}

function buildSearchParameters(mrgData, pagingType) {
	return {
		mergeData: mrgData || '',
		pagingType: pagingType || 'C',
		requestType: getValueOrDefault(sele_REQ_TYPE, EMPTY_VALUE),
		departmentCode: getValueOrDefault(auto_S_DEPCD, EMPTY_VALUE),
		requestQuantity: getValueOrDefault(sele_REQQTY, EMPTY_VALUE),
		lotExpirationPeriod: getValueOrDefault(sele_RSV_LEP, EMPTY_VALUE),
		partNumber: getValueOrDefault(inpu_RSV_PTNO, EMPTY_VALUE),
		vendorMain: getValueOrDefault(auto_VNDCD_MN, EMPTY_VALUE),
		vendorSub: getValueOrDefault(auto_VNDCD_SB, EMPTY_VALUE),
		processType: getValueOrDefault(sele_PROCTY, EMPTY_VALUE),
		startDate: inpu_REQDT_FIRST.getValue(),
		endDate: inpu_REQDT_LAST.getValue()
	};
}

function validateSearchDates(startDate, endDate) {
	if (!validateDate(startDate, "시작일")) return false;
	if (!validateDate(endDate, "종료일")) return false;
	
	if (startDate > endDate) {
		alert("시작일이 종료일보다 클 수 없습니다.");
		return false;
	}
	
	var dayInterval = getDayInterval(startDate, endDate);
	if (dayInterval > 31) {
		alert("조회 기간은 31일을 초과할 수 없습니다.");
		return false;
	}
	
	return true;
}

function executeSearch(params) {
	FV_TIMESTAMP = '';
	grid1.removeAll();
	tit_ClearActionInfo();
	
	setupSearchQuery(params.pagingType);
	addSearchParameters(params);
	
	tit_CallService("HAIMS_COLL_ACTION", "", "fn_AfterSelect");
}
```

각 함수가 하나의 일만 한다. 이름만 봐도 뭐 하는지 명확하다.

<br>

## 문제점 7: 전역 변수 남발

```javascript
FV_TIMESTAMP = '';
```

`FV_TIMESTAMP`가 어디서 선언됐는지 모른다. 전역 변수다.

전역 변수는 위험하다. 어디서든 수정할 수 있다. 디버깅이 어렵다.

```javascript
var searchState = {
	timestamp: '',
	lastSearchParams: null
};

function resetSearchState() {
	searchState.timestamp = '';
	searchState.lastSearchParams = null;
}
```

객체로 감싼다. 스코프를 제한한다.

<br>

## 문제점 8: 하드코딩된 쿼리 ID

```javascript
if(pagingType == 'B'){
	tit_AddSearchActionInfo("collect:HT09_W01_S01");
}else{
	tit_AddSearchActionInfo("collect:HT09_W01_S05");
	
	if(pagingType == 'C'){
		tit_AddSearchActionInfo("collect:HT09_W01_S06");
	}
}
```

`"collect:HT09_W01_S01"` 같은 쿼리 ID가 코드 곳곳에 박혀있다.

나중에 쿼리 ID를 바꿔야 하면? 전체 검색해서 하나씩 바꿔야 한다. 오타 한 번 내면 버그다.

```javascript
var QUERY_ID = {
	SEARCH_BACK: "collect:HT09_W01_S01",
	SEARCH_DEFAULT: "collect:HT09_W01_S05",
	SEARCH_SUMMARY: "collect:HT09_W01_S06"
};

function setupSearchQuery(pagingType) {
	if (pagingType === PAGING_TYPE_BACK) {
		tit_AddSearchActionInfo(QUERY_ID.SEARCH_BACK);
	} else {
		tit_AddSearchActionInfo(QUERY_ID.SEARCH_DEFAULT);
		
		if (pagingType === PAGING_TYPE_INITIAL) {
			tit_AddSearchActionInfo(QUERY_ID.SEARCH_SUMMARY);
		}
	}
}
```

<br>

## 문제점 9: fn_AfterSelect의 반복문

```javascript
for(i=0; i < rcount; i++){
	if(Number(grid1.getCellData( i , "PROC_QTY" )) > Number(grid1.getCellData( i , "INV_AVLQT" ))){
		grid1.setCellColor( i , "PROC_QTY" 	  , 'red' );
	}else{
		grid1.setCellColor( i , "PROC_QTY" 	  , 'black' );
	}
	
	if(Number(grid1.getCellData( i , "WSN_SALECST" )) > 0 && Number(grid1.getCellData( i , "WSN_SALECST" )) !== Number(grid1.getCellData( i , "SALE_PRC" ))){
		grid1.setCellColor( i , "WSN_SALECST" 	  , 'red' );
	}else{
		grid1.setCellColor( i , "WSN_SALECST" 	  , 'black' );
	}
	
	if(grid1.getCellData( i , "IRN_AG_USRTY" ) === "P" || grid1.getCellData( i , "IRN_AG_USRTY" ) === "O"){
		grid1.setCellReadOnly( i ,"SALE_PRC" , true);
	}
	
	if(grid1.getCellData( i , "FINAL_STAT" ) === "판매완료"){
		grid1.setCellReadOnly( i ,"IRN_LEP" , true);
		grid1.setCellReadOnly( i ,"IRN_PTNO" , true);
		grid1.setCellReadOnly( i ,"WHSCD" , true);
		grid1.setCellReadOnly( i ,"IRN_DMD_QTY" , true);
		grid1.setCellReadOnly( i ,"PROC_QTY" , true);
		grid1.setCellReadOnly( i ,"SALE_PRC" , true);
		grid1.setCellReadOnly( i ,"SPEC_YN" , true);
	} 
	
	if(Number(grid1.getCellData( i , "SHP_CNT" )) == 0 ){
		grid1.setCellReadOnly( i ,"IRN_APR_DATE" , true);
		grid1.setCellBackgroundColor( i , "IRN_APR_DATE", 'gray' );
	}
}
```

한 반복문 안에 if문이 4개다. 각각 뭐 하는지 파악하기 힘들다.

```javascript
function applyGridRowStyles(rowIndex) {
	applyQuantityColor(rowIndex);
	applySaleCostColor(rowIndex);
	applyReadOnlyRules(rowIndex);
}

function applyQuantityColor(rowIndex) {
	var processQty = Number(grid1.getCellData(rowIndex, "PROC_QTY"));
	var availableQty = Number(grid1.getCellData(rowIndex, "INV_AVLQT"));
	var color = processQty > availableQty ? 'red' : 'black';
	
	grid1.setCellColor(rowIndex, "PROC_QTY", color);
}

function applySaleCostColor(rowIndex) {
	var wsnSaleCost = Number(grid1.getCellData(rowIndex, "WSN_SALECST"));
	var salePrice = Number(grid1.getCellData(rowIndex, "SALE_PRC"));
	var color = (wsnSaleCost > 0 && wsnSaleCost !== salePrice) ? 'red' : 'black';
	
	grid1.setCellColor(rowIndex, "WSN_SALECST", color);
}

function applyReadOnlyRules(rowIndex) {
	var userType = grid1.getCellData(rowIndex, "IRN_AG_USRTY");
	var finalStatus = grid1.getCellData(rowIndex, "FINAL_STAT");
	var shipmentCount = Number(grid1.getCellData(rowIndex, "SHP_CNT"));
	
	if (userType === USER_TYPE_POLICE || userType === USER_TYPE_ARMY) {
		grid1.setCellReadOnly(rowIndex, "SALE_PRC", true);
	}
	
	if (finalStatus === "판매완료") {
		setMultipleCellsReadOnly(rowIndex, [
			"IRN_LEP", "IRN_PTNO", "WHSCD", 
			"IRN_DMD_QTY", "PROC_QTY", "SALE_PRC", "SPEC_YN"
		]);
	}
	
	if (shipmentCount === 0) {
		grid1.setCellReadOnly(rowIndex, "IRN_APR_DATE", true);
		grid1.setCellBackgroundColor(rowIndex, "IRN_APR_DATE", 'gray');
	}
}

function setMultipleCellsReadOnly(rowIndex, columnNames) {
	for (var i = 0; i < columnNames.length; i++) {
		grid1.setCellReadOnly(rowIndex, columnNames[i], true);
	}
}

// 사용
var rowCount = grid1.getRowCount();
for (var i = 0; i < rowCount; i++) {
	applyGridRowStyles(i);
}
```

함수 이름만 봐도 뭐 하는지 안다. 테스트하기도 쉽다.

<br>

## 문제점 10: 날짜 관련 주석이 연도만 있다

```javascript
//2014.10.30 : 청구번호 중복체크
var tmpDmdnoArr = text_DMDREMARK.getValue().replaceAll(" ", "").split(",");

//2014.08.12 추가
if(inpu_REQDT_FIRST.getValue() > inpu_REQDT_LAST.getValue()){

//2014.12.05 SQL 튜닝으로 인한 처리
var usrAgtcdH = hidden_USR_AGTCD_H.getValue();

//2015.08.27 RONO추가
var strRONo = "";

//2020.02.07 REMARK추가
var strREMARK = "";
```

언제 추가했는지만 적혀있다. 왜 추가했는지는 없다.

5년 뒤에 보면 "2015.08.27에 누가 왜 추가했지?"만 남는다.

```javascript
// 검색 조건에 RO번호 추가 (2015.08.27, 김철수 - 요청자: 영업팀)
// 부분 일치 검색을 위해 LIKE 패턴 사용
function buildWildcardValue(inputComponent) {
	var value = trim(inputComponent.getValue());
	return value !== "" ? "%" + value + "%" : "";
}
```

이렇게 쓴다. 날짜보다 이유가 중요하다.

<br>

## 개선된 전체 코드

```javascript
// 상수 정의
var EMPTY_VALUE = '-999';
var PAGING_TYPE_INITIAL = 'C';
var PAGING_TYPE_BACK = 'B';
var USER_TYPE_POLICE = 'P';
var USER_TYPE_ARMY = 'O';
var MAX_SEARCH_DAYS = 31;
var DATE_LENGTH = 8;

var QUERY_ID = {
	SEARCH_BACK: "collect:HT09_W01_S01",
	SEARCH_DEFAULT: "collect:HT09_W01_S05",
	SEARCH_SUMMARY: "collect:HT09_W01_S06"
};

// 메인 조회 함수
function fn_Select(mergeData, pagingType) {
	if (!validateDemandNumber()) {
		return false;
	}
	
	var params = buildSearchParameters(mergeData, pagingType);
	
	if (!validateSearchDates(params.startDate, params.endDate)) {
		return false;
	}
	
	executeSearch(params);
}

// 청구번호 검증
function validateDemandNumber() {
	if (fn_IsEmpty(text_DMDREMARK.getValue())) {
		return true;
	}
	
	var demandNumbers = text_DMDREMARK.getValue().replaceAll(" ", "").split(",");
	var uniqueDemandNumbers = arrayDuplicate(demandNumbers);
	text_DMDREMARK.setValue(uniqueDemandNumbers);
	
	var xmlData = buildDemandNumberXML(text_DMDREMARK.getValue());
	fn_SaveDMD(xmlData);
	
	return false;
}

// 청구번호 XML 생성
function buildDemandNumberXML(demandNumbers) {
	var formatted = demandNumbers.replace(/,/gi, "</A></H><H><A>");
	return "<dataset><H><A>" + formatted + "</A></H></dataset>";
}

// 검색 파라미터 구성
function buildSearchParameters(mergeData, pagingType) {
	return {
		mergeData: mergeData || '',
		pagingType: pagingType || PAGING_TYPE_INITIAL,
		requestType: getValueOrDefault(sele_REQ_TYPE, EMPTY_VALUE),
		departmentCode: getValueOrDefault(auto_S_DEPCD, EMPTY_VALUE),
		requestQuantity: getValueOrDefault(sele_REQQTY, EMPTY_VALUE),
		lotExpirationPeriod: getValueOrDefault(sele_RSV_LEP, EMPTY_VALUE),
		partNumber: getValueOrDefault(inpu_RSV_PTNO, EMPTY_VALUE),
		vendorMain: getValueOrDefault(auto_VNDCD_MN, EMPTY_VALUE),
		vendorSub: getValueOrDefault(auto_VNDCD_SB, EMPTY_VALUE),
		processType: getValueOrDefault(sele_PROCTY, EMPTY_VALUE),
		userAgentCodeH: hidden_USR_AGTCD_H.getValue() || "",
		userAgentCodeK: hidden_USR_AGTCD_K.getValue() || "",
		roNumber: buildWildcardValue(inpu_RONO),
		remark: buildWildcardValue(text_TRFREMARK),
		startDate: inpu_REQDT_FIRST.getValue(),
		endDate: inpu_REQDT_LAST.getValue()
	};
}

// 컴포넌트 값 또는 기본값 반환
function getValueOrDefault(component, defaultValue) {
	var value = component.getValue();
	return fn_IsEmpty(value) ? defaultValue : value;
}

// 와일드카드 값 생성
function buildWildcardValue(inputComponent) {
	var value = trim(inputComponent.getValue());
	return value !== "" ? "%" + value + "%" : "";
}

// 날짜 검증
function validateSearchDates(startDate, endDate) {
	if (!validateDate(startDate, "시작일")) return false;
	if (!validateDate(endDate, "종료일")) return false;
	
	if (startDate > endDate) {
		alert("시작일이 종료일보다 클 수 없습니다.");
		return false;
	}
	
	var dayInterval = getDayInterval(startDate, endDate);
	if (dayInterval > MAX_SEARCH_DAYS) {
		alert("조회 기간은 " + MAX_SEARCH_DAYS + "일을 초과할 수 없습니다.");
		return false;
	}
	
	return true;
}

// 개별 날짜 검증
function validateDate(dateValue, fieldName) {
	if (!dateValue || dateValue.trim().length !== DATE_LENGTH) {
		alert(fieldName + "의 형식이 올바르지 않습니다. (YYYYMMDD)");
		return false;
	}
	
	var datePattern = /^(19[0-9]{2}|2[0-9]{3})(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])$/;
	if (!dateValue.match(datePattern)) {
		alert(fieldName + "이 유효한 날짜가 아닙니다.");
		return false;
	}
	
	return true;
}

// 검색 실행
function executeSearch(params) {
	resetSearchState();
	initializeGrid();
	setupSearchQuery(params.pagingType);
	addSearchParameters(params);
	
	tit_CallService("HAIMS_COLL_ACTION", "", "fn_AfterSelect");
}

// 검색 상태 초기화
function resetSearchState() {
	FV_TIMESTAMP = '';
}

// 그리드 초기화
function initializeGrid() {
	grid1.removeAll();
	tit_ClearActionInfo();
}

// 검색 쿼리 설정
function setupSearchQuery(pagingType) {
	if (pagingType === PAGING_TYPE_BACK) {
		tit_AddSearchActionInfo(QUERY_ID.SEARCH_BACK);
	} else {
		tit_AddSearchActionInfo(QUERY_ID.SEARCH_DEFAULT);
		
		if (pagingType === PAGING_TYPE_INITIAL) {
			tit_AddSearchActionInfo(QUERY_ID.SEARCH_SUMMARY);
		}
	}
}

// 검색 파라미터 추가
function addSearchParameters(params) {
	tit_AddInputParamData("AGTCD", FV_AGTCD);
	tit_AddInputParamData("FR_DT", params.startDate);
	tit_AddInputParamData("TO_DT", params.endDate);
	tit_AddInputParamData("IRN_DMD_TYPE", params.requestType);
	tit_AddInputParamData("INV_AVLQT", params.requestQuantity);
	tit_AddInputParamData("LEP", params.lotExpirationPeriod);
	tit_AddInputParamData("PTNO", params.partNumber);
	tit_AddInputParamData("VEN_M", params.vendorMain);
	tit_AddInputParamData("VEN_S", params.vendorSub);
	tit_AddInputParamData("FINAL_STAT", params.processType);
	tit_AddInputParamData("DEPCD", params.departmentCode);
	tit_AddInputParamData("MERGEVALUE", params.mergeData);
	tit_AddInputParamData("PAGING_TYPE", params.pagingType);
	tit_AddInputParamData("USR_AGTCD_H", params.userAgentCodeH);
	tit_AddInputParamData("USR_AGTCD_K", params.userAgentCodeK);
	tit_AddInputParamData("RONO", params.roNumber);
	tit_AddInputParamData("REMARK", params.remark);
}

// 조회 콜백
function fn_AfterSelect() {
	if (!gfn_isTransactionSuccess(tit_GetErrorLog("CODE", "res"))) {
		alert('일치하는 데이터가 없습니다.');
		return;
	}
	
	loadGridData();
	applyGridStyles();
	updateSummary();
	updateButtonStates();
	clearRemarkField();
}

// 그리드 데이터 로드
function loadGridData() {
	var dataNode = WebSquare.ModelUtil.findInstanceNode("res/root/dataset[@id='dsOutHT09_W01_S01']");
	grid1.setXML(dataNode);
	
	irnDmdType = WebSquare.ModelUtil.getInstanceValue("res/root/dataset[@id='dsOutHT09_W01_S01']/record/IRN_DMD_TYPE");
	console.log("irnDmdType : ", irnDmdType);
	
	grid1.checkAll(grid1.getColumnIndex("CHK"), '1');
	grid1.setHeaderValue("head_CHK", true);
}

// 그리드 스타일 적용
function applyGridStyles() {
	var rowCount = grid1.getRowCount();
	
	for (var i = 0; i < rowCount; i++) {
		applyGridRowStyles(i);
	}
}

// 개별 행 스타일 적용
function applyGridRowStyles(rowIndex) {
	applyQuantityColor(rowIndex);
	applySaleCostColor(rowIndex);
	applyReadOnlyRules(rowIndex);
}

// 수량 색상 적용
function applyQuantityColor(rowIndex) {
	var processQty = Number(grid1.getCellData(rowIndex, "PROC_QTY"));
	var availableQty = Number(grid1.getCellData(rowIndex, "INV_AVLQT"));
	var color = processQty > availableQty ? 'red' : 'black';
	
	grid1.setCellColor(rowIndex, "PROC_QTY", color);
}

// 판매가 색상 적용
function applySaleCostColor(rowIndex) {
	var wsnSaleCost = Number(grid1.getCellData(rowIndex, "WSN_SALECST"));
	var salePrice = Number(grid1.getCellData(rowIndex, "SALE_PRC"));
	var color = (wsnSaleCost > 0 && wsnSaleCost !== salePrice) ? 'red' : 'black';
	
	grid1.setCellColor(rowIndex, "WSN_SALECST", color);
}

// 읽기 전용 규칙 적용
function applyReadOnlyRules(rowIndex) {
	var userType = grid1.getCellData(rowIndex, "IRN_AG_USRTY");
	var finalStatus = grid1.getCellData(rowIndex, "FINAL_STAT");
	var shipmentCount = Number(grid1.getCellData(rowIndex, "SHP_CNT"));
	
	if (userType === USER_TYPE_POLICE || userType === USER_TYPE_ARMY) {
		grid1.setCellReadOnly(rowIndex, "SALE_PRC", true);
	}
	
	if (finalStatus === "판매완료") {
		setMultipleCellsReadOnly(rowIndex, [
			"IRN_LEP", "IRN_PTNO", "WHSCD", 
			"IRN_DMD_QTY", "PROC_QTY", "SALE_PRC", "SPEC_YN"
		]);
	}
	
	if (shipmentCount === 0) {
		grid1.setCellReadOnly(rowIndex, "IRN_APR_DATE", true);
		grid1.setCellBackgroundColor(rowIndex, "IRN_APR_DATE", 'gray');
	}
}

// 여러 셀 읽기 전용 설정
function setMultipleCellsReadOnly(rowIndex, columnNames) {
	for (var i = 0; i < columnNames.length; i++) {
		grid1.setCellReadOnly(rowIndex, columnNames[i], true);
	}
}

// 요약 정보 업데이트
function updateSummary() {
	var totalCount = WebSquare.ModelUtil.getInstanceValue("res/root/dataset[@id='dsOutHT09_W01_SUMMARY']/record/TOTCNT");
	inpu_TOTCNT.setValue(totalCount);
	fn_ExcelB_Ctrl();
}

// 버튼 상태 업데이트
function updateButtonStates() {
	var hasData = grid1.getRowCount() > 0;
	
	trig_Save.setDisabled(!hasData);
	trigger18.setDisabled(!hasData);
	trigger191.setDisabled(!hasData);
}

// 비고 필드 초기화
function clearRemarkField() {
	text_TRFREMARK.setValue('');
}
```

<br>

## 개선 효과

**가독성**

함수 이름만 봐도 뭐 하는지 안다. 각 함수가 10~20줄이라 한 화면에 들어온다.

**유지보수**

버그 수정할 때 해당 함수만 보면 된다. 중복 코드가 없어서 한 곳만 고쳐도 전체에 반영된다.

**테스트**

각 함수를 독립적으로 테스트할 수 있다. 검증 로직만 따로 떼서 테스트 가능하다.

**확장**

새 검증 규칙 추가가 쉽다. 새 필드 추가도 간단하다.

<br>

## 정리

레거시 코드의 공통점
1. **변수 선언이 위에 몰려있다** - 사용하는 곳과 100줄 떨어짐
2. **매직 넘버/스트링** - 의미 파악 불가
3. **같은 패턴 반복** - 복사 붙여넣기의 향연
4. **주석 처리된 코드** - 지워야 할 것들
5. **날짜 검증 중복** - 같은 에러 메시지 3번
6. **거대한 함수** - 한 함수가 너무 많은 일을 한다
7. **전역 변수** - 어디서든 수정 가능
8. **하드코딩된 값** - 쿼리 ID 같은 것들
9. **반복문에 모든 처리** - 한 곳에서 다 함
10. **날짜만 있는 주석** - 왜 추가했는지 없음

리팩토링 원칙
1. **사용하는 곳에서 선언** - 변수 선언과 사용을 가깝게
2. **상수 사용** - 매직 넘버 제거
3. **함수 추출** - 같은 패턴 반복하지 않기
4. **죽은 코드 삭제** - Git이 있다
5. **검증 로직 통합** - 한 곳에서 처리
6. **함수는 한 가지 일만** - Single Responsibility
7. **스코프 제한** - 전역 변수 최소화
8. **의미 있는 이름** - 쿼리 ID도 상수로
9. **함수 분리** - 반복문 안의 로직도 함수로
10. **의미 있는 주석** - 날짜보다 이유

레거시 코드를 만나도 겁먹지 않는다. 천천히 분해하면 된다. 함수 하나씩만 개선해도 된다.

10년 뒤 이 코드를 볼 사람을 생각하면서 쓴다.

