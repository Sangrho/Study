## Resource 계산
Druid 서버 구축 시 Resource 계산하는 방법

## 결과
![image](https://user-images.githubusercontent.com/4033129/44767046-27be6280-ab97-11e8-9044-7a8c6f25dfd9.png)


## 고민 과정
1.MiddleManager세팅 {(druid.server.http.numThreads) , (druid.server.http.numThreads)} 무시했을 경우 + Overlord, Coordinator 무시했을 경우<br/>
2.Overlord, Coordinator 를 각각 기본으로 1 core 씩 할당했을 경우<br/>
3.Peon 설정(Prefix) 적용 안됨, Peon 갯수만 증가 시킨 경우 + Overlord, Coordinator 무시했을 경우<br/>
4.Peon 설정(Prefix) 적용 됨, Peon 갯수만 증가 시킨 경우 + Overlord, Coordinator 무시했을 경우<br/>
5.Peon 설정(Prefix) 적용 안 됨, Peon 갯수만 증가 시킨 경우 + Overlord, Coordinator 를 각각 기본으로 1 core 씩 할당했을 경우<br/>
6.Peon설정(Prefix) 적용 됨, Peon 갯수만 증가 시킨 경우 + Overlord, Coordinator 를 각각 기본으로 1 core 씩 할당했을 경우 >채택<br/><br/>

## Test 시 이슈
<img width="1303" alt="image" src="https://user-images.githubusercontent.com/4033129/44767119-7835c000-ab97-11e8-9d51-ff1efc4fdd47.png">

## Component 별 계산 근거
![image](https://user-images.githubusercontent.com/4033129/44767145-9996ac00-ab97-11e8-80b8-ed13fdc343ff.png)
![image](https://user-images.githubusercontent.com/4033129/44767147-9bf90600-ab97-11e8-9c77-3b5c99ae4672.png)
![image](https://user-images.githubusercontent.com/4033129/44767150-9dc2c980-ab97-11e8-8bab-320e302ee996.png)
![image](https://user-images.githubusercontent.com/4033129/44767155-a3201400-ab97-11e8-96ee-c01373822956.png)

## Check list
![image](https://user-images.githubusercontent.com/4033129/44767177-c0ed7900-ab97-11e8-8e05-3cc784f0d8bb.png)
![image](https://user-images.githubusercontent.com/4033129/44767192-d06cc200-ab97-11e8-8559-1441bfae8bd9.png)
![image](https://user-images.githubusercontent.com/4033129/44767214-ed08fa00-ab97-11e8-8b36-ab060ac56a96.png)
