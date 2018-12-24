## Scala의 값 표현과 평가

### 표현식의 평가 방법
- **val**과 **lazy val**의 차이 알아보기
    - val을 이용한 방법 
        ```
        object Evaluation extends App {
            val cooktimeInMin = {
                println("Hi I'm cup noodle!")
                4
            }
            println("Let's start cooking!")
            println("Cup noodle takes " + cooktimeInMin + " min.")
        }
        ```
        ```
        Hi I'm cup noodle!
        Let's start cooking!
        Cup noodle takes 4 min.
        ```
        - 정의 된 직후 변수가 평가된다
    - lazy val을 이용한 방법 
        ```
        object Evaluation extends App {
            lazy val cooktimeInMin = {
                println("Hi I'm cup noodle!")
                4
            }
            println("Let's start cooking!")
            println("Cup noodle takes " + cooktimeInMin + " min.")
        }
        ```
        ```
        Let's start cooking!
        Hi I'm cup noodle!
        Cup noodle takes 4 min.
        Oh, 4 min is soooo short!
        ```
        - val과 다르게 *procedure* 하지 않게, 변수 사용시에 **해당 변수에 대한 평가**가 일어난다.
        - 정의된 변수가 처음 사용될 때 평가된다는 의미
    - def를 사용할 때
        - def의 경우, 변수가 매번 사용될 때마다 평가된다.
    - var를 이용한 정의
        - 추후 변할 값이 있을 때 사용한다.
        - val의 경우, 값을 재정의 할 수 없다.


referenced by [holaxprogramming](https://www.holaxprogramming.com/2017/11/18/scala-value-naming/)
