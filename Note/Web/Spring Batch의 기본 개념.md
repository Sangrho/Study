## Spring Batch의 기본 개념
- 기본 개념
    - ![image](https://user-images.githubusercontent.com/10006290/49298044-b7114400-f4ff-11e8-95bc-bb235df86ffc.png)
        - **Job**
            - Batch에서 실행 가능한 실행 단위
        - **JobLauncher**
            - Job을 실행
            - JobRepository를 통해 Job, Step, Item등을 생성하고 조합
        - **JobRepository**
            - DB또는 어딘가에 저장된 Job, Step 등을 조회 또는 생성, 수정
            - Select, Insert, Update
        - **Step**
            - ```Job = Step * (1~n)```
            - Job의 통제를 받으며 Job안에서 실행 가능한 Job보다 작은 실행 단위
        - **ItemReader**
            - Step = 0~1개의 ItemReader를 포함
            - 데이터를 어디선가(DB, File, Memory 등) 조회하는 역할
        - **ItemProcessor**
            - Step = 0~1개의 ItemProcessor를 포함
            - **ItemReader**를 통해 조회한 데이터를 중간에서 가공하는 역할
        - **ItemWriter**
            - Step = 0~1개의 ItemWriter를 포함
            - ItemProcessor를 통해 가공된 데이터를 Write 하는 역할
            - 쓰기만 가능한 것은 아님
- Step, Item*(ItemReadder, Processor, ItemWriter)
    - ItemReader, ItemProcessor, Itemwriter는 Step에 포함
        - 또한 하나의 묶음 형태
    - Item* 객체가 반드시 Step에 포함되지 않아도 되지만,
        **읽고, 가공하고, 쓰고**를 기본 동작으로 작동함
- Job Diagram
    - ![image](https://user-images.githubusercontent.com/10006290/49298570-1885e280-f501-11e8-9528-5db04dc7036a.png)
- Job
    - Job은 **여러개의 Step을 포함하는 객체**
        - reference에서는 **step의 container**로 표현
    - SimpleJob : Job의 구현체
        - ```private List<Step> steps = new ArrayList<Step>();```
        - Step의 List로 구성됨
- JobInstance
    - **JobRepository**를 통해 *조회*또는 *생성*
    - Job의 논리적인 실행 단위 객체
    - 단순히 job의 **name**과 **id**를 필드로 선언
- JobExecution
    - **JobRepository**를 통해 *조회*또는 *생성*
    - Job 실행시 필요한 정보를 아래와 같이 담고 있음
    - 현재 실행되고 있는 Batch의 상태를 **BatchStatus**에 담고 있다.
        - [속성정보](https://docs.spring.io/spring-batch/trunk/reference/htmlsingle/#domainJobExecution)
        ```
        private final JobParameters jobParameters;
        private JobInstance jobInstance;
        private volatile Collection<StepExecution> stepExecutions = Collections.synchronizedSet(new LinkedHashSet<>());
        private volatile BatchStatus status = BatchStatus.STARTING;
        private volatile Date startTime = null;
        private volatile Date createTime = new Date(System.currentTimeMillis());
        private volatile Date endTime = null;
        private volatile Date lastUpdated = null;
        private volatile ExitStatus exitStatus = ExitStatus.UNKNOWN;
        private volatile ExecutionContext executionContext = new ExecutionContext();
        private transient volatile List<Throwable> failureExceptions = new CopyOnWriteArrayList<>();
        private final String jobConfigurationName;
        ```
- JobParameter
    - Job을 실행하는데 필요한 **parameter**정보를 **key, value**형태로 담는다.
- JobRepository(SimpleRepository)
    - SimpleJobRepository는 [JdbcTemplate](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/jdbc/core/JdbcTemplate.html)
        - JobInstance
        - JobExecution
        - JobExecutionParameter
        - StepExecution
    - 등을 저장하고 조회한다.
- Step Diagram
    - ![image](https://user-images.githubusercontent.com/10006290/49299100-44559800-f502-11e8-9272-ba7145a12aeb.png)
- Step
    - 하나의 Job은 여러개의 Step을 포함
    - 단계를 정의할 수 있는 객체
    - Step에서 실제 Batch Job을 처리하는 작업의 일부 또는 전체를 수행
    - Job이 여러개의 Step을 포함시키는다는 것은
        - 여러가지 단계를 거쳐 Batch Job을 처리할 수 있다는 의미
    - Step은 **ItemReader, ItemProcessor, ItemWriter**를 포함한다.
- StepExecution
    - Step의 상태와 Step을 실행하기 위한 속성
    - 자세한 [속성정보](https://docs.spring.io/spring-batch/trunk/reference/htmlsingle/#domainStepExecution)
- StepBuilder(SimpleStepBuilder)
    - Step을 생성하기 위한 클래스
    - Step을 생성하는데 필요한 **Item\***과
        - 그 외 여러 속성들을 주입해 생성한다.
- ItemReader
    - Step에 포함되며, 데이터 읽기를 담당
- ItemProcessor
    - Step에 포함되며, ItemReader로 읽은 데이터 가공
- ItemWriter
    - Step에 포함
    - ItemReader로 읽고, ItemProcessor로 가공된 후
        - ItemWriter로 전달받아 쓰여진다
    - 단순히 데이터를 저장(insert)뿐만 아니라,
        - 읽고, 가공된 데이터의 후처리를 의미



referenced by [woniper](http://blog.woniper.net/356)