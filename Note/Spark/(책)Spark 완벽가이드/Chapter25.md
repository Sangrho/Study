### CHAPTER 25 데이터 전처리 및 피처 엔지니어링   
고급 분석을 수행하는 데 있어 가장 큰 과제이자 시간 소모가 큰 작업 중 하나가 데이터 전처리 이다.  
전처리 작업은 특별히 복잡한 프로그래밍보다는 작업 대상 데이터에 대한 깊은 지식과 그러한 데이터를 성공적으로 활용하기 위한 모델의 이해가 필요하다.  
  
#### 25.1 사용 목적에 따라 모델 서식 지정하기   
* MLlib 의 각 고급 분석 작업을 위한 입력 데이터 구조 관련 요구사항  
	- 대부분의 분류 및 회귀 알고리즘의 경우 데이터를 Double 타입의 컬럼으로 가져와서 레이블을 표시하고, Vector 타입(밀도가 높거나 희소한) 의 컬럼을 사용하여 특징을 나타내야 한다.  
	- 추천 알고리즘의 경우 데이터를 사용자 컬럼, 영화 또는 서적 등을 나타내는 아이템 컬럼, 그리고 사용자 평점 등을 나타내는 등급 컬럼으로 표현해야 한다.  
	- 비지도 학습 알고리즘의 경우 입력 데이터로 사용할 특징을 Vector타입(밀도가 높거나 희소한) 의 컬럼으로 표현해야 한다.  
	- 그래프 분석의 경우 정점과 에지가 각각 DataFrame 으로 구성되어야 한다.  
  
이러한 다양한 형태의 데이터를 확보하는 가장 좋은 방법은 변환자를 사용하는 것이다.  
  
상세 설명을 위해 아래와 같은 DF 를 생성한다.  
``` python  
sales  
fakeIntDF  
simpleDF  
scaleDF  
```  
(MLlib 은 아직 Null 값이 존재하는 경우 동작하지 않는 경우가 있다.)  
  
#### 25.2 변환자   
주 역할은 새로운 상호작용 변수를 생성하거나 컬럼을 정규화하거나 모델에 입력하기 위해 변수를 Double 타입으로 변환시키는 기능을 하며, 주로 데이터 전처리 또는 특징 생성을 위해 사용된다.  
  
![image](https://user-images.githubusercontent.com/4033129/83353893-93e38100-a390-11ea-8369-5fb7ebba2cf7.png)  
  
변환자의 예 중에는 Tokenizer 가 있는데, 주어진 문자열을 토큰화 하고 주어진 문자로 분할 한다. 비록 데이터를 학습하지는 않는다.  
  
#### 25.3 전처리 추정자   
수행하려는 변환이 입력 컬럼에 대한 데이터 또는 정보로 초기화되어야 할 때 필요하다.  
예로는 특정 컬럼의 값들의 분포를 평균이 0이고 분산이 1이 되도록 정규화하는 데 사용할 값을 계산해야한다.  
즉, 추정자는 단순 변환을 위해 맹목적으로 적용하는 일반 변환자 유형과 데이터에 따라 변환을 수행하는 추정자 유형이 있다.  
  
![image](https://user-images.githubusercontent.com/4033129/83353914-c1c8c580-a390-11ea-90fb-b7f7f5c0e5dd.png)  
  
##### 25.3.1 변환자 속성 정의하기  
모든 변환자는 적어도 입력과 출력의 컬럼 이름을 나타내는 inputCol 과 outputCol 을 지정해야 한다.  
  
#### 25.4 고수준 변환자   
RFormula 같은 고수준 변환자를 사용하면 하나의 ㅂ녀환에서 여러 가지 변환을 간결하게 지정할 수 있다.  
  
##### 25.4.1 RFormula  
일반적인 형태의 데이터에 사용할 수 있는 가장 간편한 변환자이다.  
R 언어에서 빌려온 변환자로서 데이터에 대한 변환을 선언적으로 간단히 지정할 수 있게 해준다.  
이 변환자를 적용하면 데이터값은 숫자형 또는 범주형이 되고, 문자열에서 값을 추출하는 등의 조작을 할 필요가 없다.  
  
One-hot encoding 을 수행해 문자열로 지정된 범주화된 입력변수를 자동으로 처리한다.  
즉, 데이터값 집합을 데이터 포인트가 개별 특정 값을 갖는지 여부를 지정하는 이진형의 컬럼 집합으로 변환한다.  
(One-hot encoding : N개의 고유한 값을 가지는 범주형 변수를 각 고유값마다 0과 1로 변환해서 N개의 숫자형 변수로 다시 표현하는 방법으로 통계분야에서는 이를 더미 변수화 또는 가변수화한다고 표현한다.)  
  
* RFormual 기본 연산자  
	- ~ : 함수에서 타깃과 향을 분리  
	- + : 연결 기호  
	- - : 삭제 기호  
	- : : 상호작용  
	- . : 모든 컬럼  
  
``` python  
from pyspark.ml.feature import RFormula  
  
supervised = RFormula(formula="lab ~ . + color:value1 | color:value2")  
supervised.fit(simpleDF).transform(simpleDF).show()  
```  
  
##### 25.4.2 SQL 변환자  
  
``` python  
from pyspark.ml.feature import SQLTransformer  
basicTransformation = SQLTransformer().setStatement("""SELECT ~ """)  
basicTransformatin.transform(sales).show()  
```  
  
##### 25.4.3 벡터 조합기  
  
``` python  
from pyspark.ml.feature import VectorAssembler  
va = VectorAssembler().setInputCols(["int1","int2","int3"])  
va.transform(fakeIntDF).show()  
```  
  
#### 25.5 연속형 특징 처리하기   
연속형 특징은 양의 무한대에서 음의 무한대까지의 숫자값을 의미한다.  
	1. 버켓팅 : 연속형 특징을 범주형 특징으로 변환할 수 있다.  
	2. 여러 요구사항에 다라 특징을 스케일링하거나 정규화 할 수 있다. 이러한 변환자는 Double 타입에서만 작동하므로 다른 형식의 숫자값이 있다면 Double 타입으로 변경해야 한다.  
  
``` python  
contDF = spark.range(20).selectExpr("cast(id as double)")  
```  
  
##### 25.5.1 버켓팅  
버켓팅 또는 구간화(binning) 에 대한 가장 직접적인 접근법은 Bucketizer를 사용하는 것이다.  
Bucketizer를 사용하면 주어진 연속형 특징을 지정한 버켓으로 분할한다.  
이때 버켓이 어떤 형태로 생성되어야 하는지 Double 타입 값으로 된 배열이나 리스트로 지정할 수 있다.  
이는 나중에 데이터셋의 특징을 단순화하거나 차후의 해석을 위해 표현을 단순화하려는 경우에 유용하다.  
예를 들어 사람의 체중을 나타내는 컬럼이 있고, 이 정보를 기반으로 어떤 값을 예측하고 싶다고 가정했을 때 어떤 경우에는 '과체중', '평균', '저체중' 의 세 가지 버켓으로 나누어 활용하는 것이 더 간단한 접근 방법일 수 있다.  
  
버켓을 지정하려면 경계를 설정해야 하는데, 버켓 포인트를 지정할 때 분할값은 다음 세 가지 요구사항을 충족해야 한다.  
	1. 분할 배열의 최솟값은 DF 의 최솟값보다 작아야 한다.  
	2. 분할 배열의 최댓값은 DF 의 최댓값보다 커야 한다.  
	3. 분할 배열은 최소 세 개 이상의 값을 지정해서 두 개 이상의 버켓을 만들도록 한다.  
  
* 하드 코딩된 값을 기반으로 분할  
``` python  
from pyspark.ml.feature import Bucketizer를  
bucketBorders = [01.0, 5.0, 10.0, 250.0, 600.0]  
bucketer = Bucketizer().setSplits(bucketBorders).setInputCol("id")  
bucketer.transform(contDF).show()  
```  
  
* 백분위수를 기준으로 분할  
``` python  
from pyspark.ml.feature import QuantileDsicretizer  
  
bucketer = QuantileDiscretizer().setNumBuckets(5).setInputCol("id").setOutputCol("result")  
fittedBucketer = bucketer.fit(contDF)  
fittedBucketer.transform(contDF).show()  
```  
  
##### 25.5.2 스케일링과 정규화  
서로 다른 단위의 여러 컬럼이 있을 때, 연속형 데이터의 범위를 스케일링(조정) 하고 정규화 한다.  
예를 들어 무게와 높이라는 두 개의 컬럼이 있는 DF 가 있을 때, 범위를 스케일링하거나 정규화하지 않으면 피트의 높이 값이 온스의 무게 값보다 훨씬 작기 때문에 알고리즘은 높이의 변화에 덜 민감하게 된다.  
  
##### 25.5.3 StandardScaler  
Feature 들이 평균이 0이고 표준편차가 1인 분포를 갖도록 데이터를 표준화 한다.  
* StandardScaler  
특징들이 평균이 0이고 표준편차가 1인 분포를 갖도록 데이터를 표준화 한다.  
  
``` python  
from pyspark.ml.feature import StandardScaler  
  
sScaler = StandardScaler().setInputCol("features")  
sSacler.fit(scaleDF).transform(scaleDF).show()  
```  
  
* MinMaxScaler  
벡터의 값을 주어진 최솟값에서 최댓값까지의 비례 값으로 스케일링한다.  
  
``` python  
from pyspark.ml.feature import MinMaxScaler  
  
minMax = MinMaxScaler().setMin(5).setMax(10).setInputCol("features")  
fittedminMax = minMax.fit(scaleDF)  
fittedminMax.transform(scaleDF).show()  
```  
  
* MaxAbsScaler  
각 값을 해당 컬럼의 최대 절댓값으로 나눠서 데이터의 범위를 조정한다. 따라서 모든 값은 -1과 1사이에서 끝난다.  
  
``` python  
from pyspark.ml.feature import MaxAbsScaler  
  
maScaler = MaxAbsScaler().setInputCol("features")  
fittedmaScaler = maScaler.fit(scaleDF)  
fittedmaScaler.transform(scaleDF).show()  
```  
  
* ElementwiseProduct  
벡터의 각 값을 임의의 값으로 조정할 수 있다.  
  
``` python  
from pyspark.ml.feature import ElementwiseProduct  
scaleUpVec = Vectors.dense(10.0, 15.0, 20.0)  
scalingUp = ElementwiseProduct().setScalingVec(scaleUpVec).setInputCol("features")  
scalingUp.transform(scaleDF).show()  
```  
  
* Normalizer  
여러 가지 표준 중 하나를 사용하여 다차원 벡터를 스케일링할 수 있따.  
  
``` python  
from pyspark.ml.feature import Normalizer  
  
manhattanDistance = Normalizer().setP(1).setInputCol("features")  
manhattanDistance.transform(scaleDF).show()  
```  
  
#### 25.6 범주형 특징 처리하기   
범주형 특징에 대한 가장 일반적인 작업은 인덱싱이다.  
인덱싱은 범주형 변수를 머신러닝 알고리즘에 적용할 수 있는 숫자형 변수로 변환한다.  
  
일반적으로 데이터 전처리를 할 때는 이로간성을 위해 모든 범주형 변수의 색인을 다시 생성하는 것이 좋다.  
시간이 지남에 따라 작업자의 인코딩 방식이 변결될 수 있으므로 장기적으로 모델을 유지 관리하는 데 도움이 될 수 있다.  
  
##### 25.6.1 StringIndexer  
색인을 생성하는 가장 간단한 방법은 문자열을 다른 숫자 Id에 매핑하는 것이다.  
  
``` python  
from pyspark.ml.feature import StringIndexer  
  
lblIndxr = StringIndexer().setInputCol("lab").setOutputCol("labellInd")  
idxRes = lblIndxr.fit(simpleDF).transform(simpleDF)  
idxRes.show()  
  
# 문자열이 아닌 컬럼에도 적용할 수 있는데, 이 경우 색인을 생성하기 전에 문자열로 변환된다.  
  
valIndexer = StringIndexer().setInputCol("value1").setOutputCol("valueInd")  
valIndexer.fit(simpleDF).transform(simpleDF).show()  
```  
  
##### 25.6.2 색인된 값을 텍스트로 변환하기  
일반적으로 머신러닝 수행 결과를 검사할 때는 다양하게 변환된 결과값을 기존 값으로 다시 매핑하여 진행한다.  
MLlib 분류 모델은 색인된 값을 사용하여 예측을 수행하며, 이러한 변환은 모델의 예측 결과(색인)을 원래 범주로 다시 변환하는 데 유용하다.  
  
```python  
from pyspark.ml.feature import IndexToString  
  
labelReverse = IndexToString().setInputCol("labelInd")  
labelReverse.transform(idxRes).show()  
```  
  
##### 25.6.3 벡터 인덱싱하기  
입력 벡터 내에 존재하는 범주형 데이터를 자동으로 찾아서 0부터 시작하는 카테고리 색인을 사용하여 범주형 특징으로 변환한다.  
  
```python  
from pyspark.ml.feature import VectorIndexer  
from pyspark.ml.linalg import Vectors  
  
idxIn = spark.createDataFrame([~~~]).toDF("features","label")  
indxr = VectorIndexer().setInputCol("features").setOutputCol("idxed").setMaxCategories(2)  
indxr.fit(idxIn).transfomr(idxIn).show()  
  
```  
  
##### 25.6.4 원-핫 인코딩  
범주형 변수를 인덱싱한 후 추갈로 수행하는 매우 보편적인 데이터 변환 기법이다.  
인덱싱이 언제나 범주형 변수를 모델에 필요한 올바른 형식으로 처리하는 것은 아니기 때문이다.  
  
```python  
from pyspark.ml.feature import OneHotEncoder, StringIndexer  
  
lblIndxr = StringIndexer().setInputCol("color").setOutputCol("colorInd")  
colorLab = lbIndxr.fit(simpleDF).transform(simpleDF.select("color"))  
ohe = OneHotEncoder().setInputCol("colorInd")  
ohe.transform(colorLab).show()  
```  
  
#### 25.7 텍스트 데이터 변환자   
텍스트는 처리하기가 매우 까다로운 데이터이다.  
  
##### 25.7.1 텍스트 토큰화하기  
- Tokenizer 사용  
- RegexTokenizer 사용  
  
##### 25.7.2 일반적인 단어 제거하기  
  
```python  
from pyspark.ml.feature import StopWordsRemover  
  
englishStopWords = StopWordsRemover.loadDefaultStopWords("english")  
stops = StopWordsRemover().setStopWords(englishStopWords).setInputCol("DescOut")  
stops.transform(tokenized).show()  
```  
  
##### 25.7.3 단어 조합 만들기  
문자열을 토근화하고 불용어를 제거하면 깔끔한 단어 집합을 특징으로 사용할 수 있다.  
이 과정에서 보통 함께 배치된 단어들을 보면서 단어 조합을 살펴보는 것이 중요하다.  
  
n-gram 을 사용해서 공통으로 발생하는 단어 시퀀스를 파악할 수 있고 그것을 다시 머신러닝 알고리즘의 입력으로 사용할 수 있다.  
  
```python  
from pyspark.ml.feature import NGram  
unigram = NGram().setInputCol("DescOut").setN(1)  
bigram = NGram().setInputCol("DescOut").setN(2)  
unigram.transform(tokenized.select("DescOut")).show(10,False)  
bigram.transform(tokenized.select("DescOut")).show(10,False)  
```  
  
##### 25.7.4 단어를 숫자로 변환하기  
단어 특징을 생성하면 모델에서 사용하기 위해 단어와 단어 조합 수를 세어야 한다.  
가장 간단한 방법은 주어진 문서에 단어 포함 여부를 바이너리 형식으로 세어서 포함하는 것이다.  
또한 CountVectorizer 를 사용할 수도 있다.  
  
* CountVectorizer  
```python  
from pyspark.ml.feature import CountVectorizer  
  
cv = CountVectorizer().setInputCol("DescOut").setOutputCol("countVec").setVocabSize(500).setMinTF(1).setMinDF(2)  
fittedCV = cv.fit(tokenized)  
fittedCV.transfomr(tokenized).show(10,False)  
```  
  
* TF-IDF  
```python  
tfIdfIn = tokenized.where("array_contains(DescOut, 'red'").select("DescOut").limit(10)  
tfIdfIn.show(10,False)  
```  
  
##### 25.7.5 Word2Vec  
단어 집합의 벡터 표현을 계산하기 위한 딥러닝 기반 도구이다.  
비슷한 단어를 벡터 공간에서 서로 가깝에 배치하여 단어를 일반화 할 수 있도록 하는 것이다.  
  
#### 25.8 특징 조작하기   
머신러닝에서 사용되는 대부분의 변환자는 다양한 방식으로 Feature space 를 좍한다.  
  
##### 25.8.1 주성분 분석  
Principal Components Analysis, PCA 는 데이터의 가장 중요한 측면을 찾는 수학적 기법이다.  
PCA 는 새로운 특징 집합('aspect') 을 작성하여 데이터의 특징 표현을 변경한다.  
각각의 새로운 특징은 기존 특징들의 조합이다.  
PCA는 데이터의 주요 정보를 포함하는 더 작은 특징 집합을 생성할 숭 ㅣㅆ다는 강점을 지니고 있으며, 이는 사용자가 모델링을 수앻라 때 입력값으로 활용된다.  
  
일반적으로 PCA는 대규모 입력 데이터셋에서 총 특징 수를 줄이기 위해 사용한다.  
이러한 상황은 보통 전체 특징 공간이 ㅂ아대하고 많은 특징이 큰 관련성이 없는 텍스트 분석에서 발생한다.  
PCA를 사용하면 수많은 특징 중에서 가장 중요한 특징 조합을 찾을 수 있으며, 머신 러닝 모델에 이렇게 선별된 특징들만 입력할 숭 ㅣㅆ다.  
  
##### 25.8.2 상호작용  
  
##### 25.8.3 다항식 전개  
모든 입력 컬럼의 상호작용 변수를 생성하는 데 사용된다.  
다항식 전개로 보고자 하는 다양한 상호작용의 범위를 지정할 수 있다.  
  
#### 25.9 특징 선택   
모델을 학습시킬 때 종종 우리가 가지고 있는 매우 다양한 후보 특징 중 일부만 선택하여 적용하고 싶을 때가 있다.  
예를 들어 다양한 특징이 강한 상관관계를 나타내거나 너무 많은 특징을 모델 학습에 사용하면 모델 과적합을 초래할 수 있다.  
이러한 프로세스를 Feature Selection 이라고 한다.  
  
##### 25.9.1 ChiSqSelector  
통계적 검정을 활용하여 예측하려는 레이블과 독립적이지 않은 특징을 식별하고 관련 없는 특징을 삭제한다.  
모델에 입력으로 사용되는 특징 수를 줄이거나 텍스트 데이터의 차원을 줄이기 위해 주로 범주 데이터와 함께 사용된다.  
  
#### 25.10 고급 주제   
변환자 및 추정자와 관련한 몇 가지 고급 주게가 있다.  
그 중 가장 보편적이고 지속해서 사용되는 두 가지 주제는 변환자 저장하기와 사용자 정의 변환자 작성하기이다.  
  
##### 25.10.1 변환자 저장하기  
일단 추정자를 사용하여 변환자를 구성하면 필요할 때마다 간단히 불러오기 위해 디스크에 기록하는 것이 유용하다.  
  
##### 25.10.2 사용자 정의 변환자 작성하기  
사용자 정의 변환자를 작성하는 것은 ML 파이프라인에 적합시키고, 하이퍼파라미터 검색에 전달할 수 있는 형식으로 자신의 비즈니스 논리 중 일부를 인코딩하려는 경우 유용할 수 있다.  
일반적으로 내장 모듈은 효율적으로 실행되도록 최적화되어 있으므로 많이 사용하지만, 때대로 그렇게 하지 못할 때도 있다.  
  
