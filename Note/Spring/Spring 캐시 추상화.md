## Spring 캐시 추상화
- Spring 3.1부터 지원
- 기존 스프링 app에서 캐시를 투명하게 추가하도록 지원
- **transaction**과 비슷하게
    - 코드에 주는 영향을 최소화
    - 다양한 캐시 솔루션을 일관성 있게 사용

- 캐시 추상화
    - Java Method에 캐싱을 적용, 캐시에 보관된 정보를 메서드의 실행 횟수 감소
    - 대상 메서드가 실행될 때마다
        - 추상화가 해당 메서드의 같은 인자로 실행 되었는가 하는 **캐싱 동작** 발생
    - 데이터가 존재한다면, **실제 메서드를 실행하지 않음**
    - 결과가 존재하지 않는다면, 해당 메서드를 실행, 결과를 캐싱
        - 다음번 호출에 사용할 수 있도록 함
    - 비용이 큰 메서드(CPU,IO)를 해당 파라미터로는 한번만 실행 가능
        - 다른 메서드를 실행하지 않고도 결과 재사용 가능
        - 호출자가 어떤 방해도 받지 않고, 캐싱 로직 투명하게 적용
    - 얼마나 호출되든지 간에
        - 인자가 같으면 -> 출력도 같다
            - 라는 메서드에서만 동작
- 두가지 관점
    - 캐싱 선언
        - 캐시 되어야 하는 메서도와 정책을 정함
    - 캐시 구성
        - 데이터를 저장하고 읽을 기반 캐시
- 캐싱 서비스 자체는 **추상화**되어 있으며
    - 캐시 데이터를 저장하는 실제 스토리지를 사용
    - 캐시 추상화로 개발자가 **캐시 로직**을 작성하지 않아도 되지만, **저장 공간을 제공하지 않음**
- 통합 가능한 두가지 캐시
    - JDK, `java.util.concurrent.ConcurrentMap`와 `Encache`이다.


### 선언적인 어노테이션 기반의 캐싱
- 두가지 Annotation
    - `@Cacheable`
        - 캐시군(Cache population)
    - `@CacheEvict`
        - 캐시 만료(cache Eviction)


- Cacheable 어노테이션
    - 캐시할 수 있는 메서드를 지정하는데 사용
    - 결과를 **캐시**에 저장하므로, 동일한 인자의 다음 호출일 때
        - 이 메서드를 실제 실행하지 않고, 캐시에 저장된 값을 반환
    - 선언 방법
        ```
        @Cacheable("books")
        public Book findBook(ISBN isbn) {...}
        ```
        - `findBook()`은 **books**라는 캐시와 연결
        - 이전에 실행된 적이 있는지 확인
        - 하나의 캐시만 선언하는 경우, annotation은 여러 이름을 지정할 수 있음
        - 최소 하나의 캐시에 저장되어 있다면 해당 값을 반환
        ```
        @Cacheable({ "books", "isbns" })
        public Book findBook(ISBN isbn) {...}
        # 기본적으로는 비활성화 된 기능
        ```
    - 기본키 생성
        - 캐시는 기본적으로 **key-value**
        - 캐시된 메서드를 호출할 때마다 **해당 키로 변환**
        - 기본 Key Generator Algorithm
            - 파라미터가 없으면 **0**
            - 파라미터가 하나 **현재 인스턴스**
            - 파라미터가 둘 이상 **모든 파라미터의 해시값**
        - 분산/유지 환경에서는 hashCode를 보관하지 않도록 변경해야함
            - JVM구현체나 운영하는 환경에 따라
                - VM 인스턴스에서 HashCode를 다른 객체에서 재사용 가능
        - 다른 Key Generator사용시 `org.springframework.cache.KeyGenerator` 인터페이스 구현
    - 커스텀 키 생성 선언
        - 캐싱 대상 메서드는 캐싱 구조에 간단하게 매핑할 수 없는 다양한 시그니처를 가질 가능성이 높음
        - 캐싱 적합도 의미를 주기
        ```
        @Cacheable("books")
        public Book findBook(ISBN isbn, boolean checkWarehouse, boolean includeUsed)
        ```
        - 두 boolean 인자는 책을 찾는데 영향을 주고 캐시에는 사용하지 않음
        - `@Cacheable` 어노테이션으로 사용자가 key 속성으로 키를 생성하는 방법 지정
            - 사용할 인자(또는 중첩된 속성)을 선택
            - 작업 실행이나, 어떤 코드도 사용하지 않고(인터페이스 포함) 임의의 메서드 호출을 위해 **spEL(Spring Framework Expression Language)**사용
        - 메서드는 코드가 달라짐에 따라 시그니처도 달라짐
            - 기본 생성자 외의 접근 추천
            - 모든 메서드에서 동작할 가능성은 거의 없음
        ```
        @Cacheable(value="books", key="#isbn"
        public Book findBook(ISBN isbn, boolean checkWarehouse, boolean includeUsed)

        @Cacheable(value="books", key="#isbn.rawNumber")
        public Book findBook(ISBN isbn, boolean checkWarehouse, boolean includeUsed)

        @Cacheable(value="books", key="T(someType).hash(#isbn)")
        public Book findBook(ISBN isbn, boolean checkWarehouse, boolean includeUsed)
        ```
    - 조건부 캐싱
        - 메서드를 항상 캐싱하는 것이 아님
        - **conditional 파라미터**를 사용한다.
        ```
        @Cacheable(value="book", condition="#name.length < 32")
        public Book findBook(String name)
        ```
    - 사용 가능한 SpEL 평가 컨텍스트
        - 각 spEL의 표현식은 context를 재평가
        - 파라미터 구성시,
            - 프레임 워크 인자 이름 같은 **메타데이터 관련된 전용 캐시**를 제공
        - `methodName, method, target, targetClass, ...`
- `@CachePut` 어노테이션
    - 메서드 실행에 영향을 주지 않고, 캐시 갱신시 사용
    - 메서드를 항상 실행하고, 그 결과를 캐시에 보관
    - 메서드 흐름의 최적화 보다 **캐시 생성(population)**에 사용해야 함
    - 동일한 메서드에 `@CachePut`과 `@Cacheable` 어노테이션을 사용하는 것을 **권장하지 않음**
        - `@CachePut` : 캐시 갱신을 하려고 실행 강제
        - `@Cacheable` : 캐시를 사용하여 메서드 실행을 건너 뛴다.
    - 특정한 코너케이스(두 @이 조건이 겹치지 않는 경우)가 아니면 선언 지양
- `CacheEvict` 어노테이션
    - 캐시 스토어의 제거
    - 오래되거나 사용하지 않는 데이터 제거
    - 캐시를 제거 하는 메서드를 구분
        - 캐시에서 **데이터를 제거하는 트리거**로 동작하는 메서드
    - 영향을 끼치는 하나 이상의 캐시 지정
    - 키나 조건을 지정할 수 있으나,
        - 캐시의 범위를 나타내는 **allEntries**파라미터를 사용할 수 있음
        ```
        @CacheEvict(value = "books", allEntries=true)
        public void loadBooks(InputStream batch)
        ```
        - 한 지여의 전체 캐시를 지워야 할때 편리하게 사용
        - 지정한 키에 적용되지 x -> 프레임워크가 무시
    - `beforeInvocation` 속성
        - 메서드 실행 이후나 이전에 제거를 해야하는 여부 지정
        - 메서드 실행 이후일 경우
            - 다른 어노테이션과 같은 의미를 가짐
            - 메서드가 성공적으로 완료시, 캐시에서 동작(or 제거)가 실행
        - 메서드가 실행되지 않거나, 캐시되어 예외가 던저지면 제거가 실행되지 않음
        - 메서드 실행 이전일 경우(`beforeInvocation=true`)
            - 메서드가 호출되기 전에 항상 제거 발생, 제거가 메서드 결과에 의존하지 않음
    - `void 메서드`에 적용할 수 있다.
        - 메서드가 **트리거**로 동작, 반환값은 무시
        - 캐시와 상호작용 하지 않음
        - 캐시에 데이터를 넣어가 갱신하여 결과가 필요한 `@Cacheable`와는 다름
- `@Caching` Annotation
    - 같은 계열의 어노테이션을 여러개 지정
        - `@CacheEvict`나 `@CachePut`에서
            - **조건**이나 **키 표현식**이 캐시에 따라 다른 경우

Referenced by. https://blog.outsider.ne.kr/1094