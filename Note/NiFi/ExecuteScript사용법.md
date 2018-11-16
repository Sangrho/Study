## ExecuteScript 사용법 (Python)

NiFi 를 사용하다보면 지역 변수를 설정하거나, 파일 내용 일부를 전처리 할 일이 필요하다.</br>
간단한 전처리는 ReplaceText 프로세서에서 정규표현식을 통해 가능하나, 연산처리가 필요할 경우 ExecuteScript 프로세서를 사용하느 것이 바람직하다.</br>
아래 예제는 Python 코들 구현했으며, XML 파일을 읽어 특정 값을 합산하고 지역 변술 지정하여 다음 프로세서에서 사용하게끔 하는 코드이다.</br>

```python
import java.io
from org.apache.commons.io import IOUtils
from java.nio.charset import StandardCharsets
from org.apache.nifi.processor.io import StreamCallback
class CalcResult(StreamCallback):
    def __init__(self):
        pass

    def process(self, inputStream, outputStream):
        text = IOUtils.toString(inputStream, StandardCharsets.UTF_8)
        text_string = str(text)
        text_string_split = text_string.split('\n')
        text_string_split_notEmpty = [x for x in text_string_split if x]
        result = 0
        # self.query_result=0
        
        self.requestid=str(text_string_split_notEmpty[0])
        del text_string_split_notEmpty[0]
        
        for i in text_string_split_notEmpty:
            result += int(i)
        self.query_result = result

flowFile = session.get()
if (flowFile != None):
    CallObject = CalcResult()
    flowFile = session.write(flowFile, CallObject)
    flowFile= session.putAttribute(flowFile, "query_result", str(CallObject.query_result))
    flowFile= session.putAttribute(flowFile, "request_id", str(CallObject.requestid))
session.transfer(flowFile, REL_SUCCESS)
session.commit()
```
</br>
아래 예제는, Kafka 에서 특정 값을 Consume 할 때(ConsumeKafka 프로세서), Consume 한 값을 지역 변수로 설정하여</br>
사용할 경우 구현한 Python 코드이다.

```python
import traceback
from org.apache.nifi.processors.script import ExecuteScript
from org.apache.nifi.processor.io import StreamCallback
from java.io import BufferedReader, InputStreamReader, OutputStreamWriter
class ExtractRequstId(StreamCallback) :
    def __init__(self) :
        pass
    def process(self, inputStream, outputStream) :
        reader = InputStreamReader(inputStream,"UTF-8")
        bufferedReader = BufferedReader(reader)
        line = bufferedReader.readLine()
        self.result = str(line)
flowFile = session.get()
if flowFile is not None :
    ConvertFilesData = ExtractRequstId()
    session.write(flowFile, ConvertFilesData)
    flowFile = session.putAttribute(flowFile, "RequestId",str(ConvertFilesData.result))
    session.transfer(flowFile, ExecuteScript.REL_SUCCESS)
```
