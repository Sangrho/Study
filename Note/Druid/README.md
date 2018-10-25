# druid_tutorial
2개의 Druid 클러스터를 운영하며 작성한 문서들을 정리하기 위한 저장소<br/>

*[ Version ]<br/>*

- Druid : 0.9.0<br/>
- Tranquility : 0.7.4<br/>
- Kafka : 0.9.0<br/>


---------------

## 코드 분석 방법 (@[buckyhan](https://github.com/buckyhan))
준비사항 : Intellij, 인터넷 가능 환경 </br>

1. Intellij 에 druid 코드로 프로젝트 생성한다.</br>
2. druid > services > src > main > java > org.apache.druid.cli > Main.java 로 이동</br>
3. Run > Edit Configuration</br>
**Main class** : org.apache.druid.cli.Main</br>
**VM options** : ${druid 실행파일 HOME}/conf/druid/\*/jvm.config</br>
**Program arguments** : server * (Druid 의 각 어플리케이션을 기동시킬 때 사용하는 커맨드에서 사용하는 Argument)</br>
**Working directory** : ${druid 소스코드 HOME}</br>
**Use classpath of module** : druid-services</br>
**JRE** : 1.8</br>

![image](https://user-images.githubusercontent.com/4033129/47478103-4a04f180-d863-11e8-9613-9106671f58d8.png)

