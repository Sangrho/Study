## Spring Annotation
- 결합성을 낮추고 유지보수성을 위해 XML로 설정을 하는 추세였으나,
    - xml이 과다하게 많아져 유지보수성에 저하가 생김
- 따라서 시스템 전체 영향, 이후 변경 가능성이 있는 것만 xml, 나머지는 `Annotation`을 활용한다.


### @Component
- `<context:component-scan>`
    - 어노테이션이 적용될 클래스를 빈으로 등록
- `<context:component-scan base-package="xxx" />`
    - **xxx**패키지 하위에 `@Component`로 선언될 클래스를 bean으로 자동 등록
- 내부적으로
    - `@Required`
    - `@Autowired`
    - `@Service`
    - `@Resource`
        - 등 다양한 어노테이션으로 Specialized 될 수 있음

### @Required
- **setter method**에 위치한다.
- 필수 property를 명시, 설정하지 않을 경우 빈 생성시 예외 발생
    ```
    public class TestBean{
        @Required
        private TestDao testDao;

        public void setTestDao(TestDao testDao){
            this.testDao = testDao;
        }
    }
    ```
- `RequiredAnnotationBeanPostProcessor` 클래스는,
    - 스프링 컨테이너에 등록된 bean 객체를 조사,
        - `@Required`로 설정되어 있는 *property* 값이 설정 되어 있는지 검사
    - 사용시, 두가지 태그중 하나를 사용
        - `<bean class="org.springframeworks.beans.factory.annotation.RequiredAnnotationBeanPostProcessor "/>`
        - `<context:annotation-config>`


### @Autowired
- 의존 관계 자동 설정
- **type**에 의존하여 객체 삽입
- Bean 객체가 존재하지 않거나, 2개 이상일 때 예외 발생
- option
    - **required**
        - 필수여부 설정
        ```
        @Autowired(required=false)
        Test test=new TestTwo(); // bean 객체가 존재하지 않을경우, TestTwo 생성
        ```
    - 같은 타입의 bean이 2개이상 존재시, 예외가 발생
        - `@Qualifier`를 사용하여 특정 빈을 사용하도록 설정
            ```
            @Autowired
            @Qualifier("test")
            private Test test;
            ```
- 세부 자료 : [Guide to Spring](https://www.baeldung.com/spring-autowire)

### @Qualifier
- `@Autowired`와 같이 사용됨
- `@Autowired`로 정의된 동일 타입의 빈 객체가 존재할때, 특정 빈을 삽입할 수 있게 함
- option
    - **name** : alias 이름


### @Resource
- `@Resource`는 `@Autowired`와 다르게 이름으로 연결된다.
    - `@Autowired(by type)`
    - `@Autowired(by name)`
- option
    - **name** : 연결될 빈 객체의 이름 입력
        `@Resource(name="test")`

### @Scope
- 범위 설정
    - prototype
    - singleton(기본값)
    - request
    - session
    - globalSession
```
@Component
@Scope(value="prototype")
public class User(){}
```

### @PostConstruct
- 의존하는 객체를 설정한 이후, 초기화 작업을 하기 위해 사용
- 특정 메서드 앞에 위치함
- Spring에 의해 instance가 생성된 이후
    - 어노테이션이 적용된 매서드 호출
- `CommonAnnotationBeanPostProcessor`클래스를 빈으로 등록
    - `<context:annotation-config>` 태그로 대신 설정 가능
```
@PostConstruct
public void init(){
    logger.info("init method");
}
```

### @PreDestroy
- 컨테이너에서 객체 제거 전, 해야할 작업 수행
- 특정 메서드 앞에 위치
- `CommonAnnotationBeanPostProcessor`클래스를 빈으로 등록
    - `<context:annotation-config>` 태그로 대신 설정 가능

### @Inject
- 특정 Framework에 종속되지 않은 어플리케이션 구성시 사용
- Spring 3부터 지원

### @Service
- **비즈니스로직(BO)**가 들어가는 Service의 빈 등록

### @Respository
- 일반적으로 **DAO**에서 사용
- `DB Exception -> DataAccessException`으로 변환

### @Controller
- Spring MVC의 Controller 클래스 선언
- `SpringContainer`나 `Servlet`을 상속할 필요 없음
- `@Controller`로 등록된 클래스 파일에 대한 bean을 자동 생성
- `component-scan`을 이용

*Refereced By [conswrold](http://cornswrold.tistory.com/8)*