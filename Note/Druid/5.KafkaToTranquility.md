## Kafka 로 부터 데이터 받는 방법
Tranquility 를 사용한다.

1. Kafka 정보<br/>
UDP Sender(java)<br/>
long L = System.currentTimeMillis() / 1000;<br/>
식으로unixtime 형식으로 보내야 하며,<br/>
끝에 초 까지 붙여주기 위해서 000을 보내야 한다.<br/>
또한JSON형태로 맞춰줘야 한다.<br/>
예제는 아래와 같다.<br/>
{"ts":1519784447000,"name":"josh","count":3}<br/>
{"ts":1519784449000,"name":"josh","count":3}<br/>
{"ts":1519784451000,"name":"josh","count":3}<br/>
{"ts":1519784453000,"name":"josh","count":3}<br/><br/>

2. Tranquility Spec
ts, demension, metric정보를 넣어줘야 한다.

예제는 아래와 같다.

    "dataSources" : {
    
      "20180228" : {
    
        "spec" : {
    
          "dataSchema" : {
    
            "dataSource" : "20180228",
    
            "parser" : {
    
              "type" : "string",
    
              "parseSpec" : {
    
                "timestampSpec" : {
    
                  "column" : "ts",
    
                  "format" : "auto"
    
                },
    
                "dimensionsSpec" : {
    
                  "dimensions" : ["name"],
    
                  "dimensionExclusions" : [
    
                    "ts"
    
                  ]
    
                },
    
                "format" : "json"
    
              }
    
            },
    
            "granularitySpec" : {
    
              "type" : "uniform",
    
              "segmentGranularity" : "FIFTEEN_MINUTE",
    
              "queryGranularity" : "minute"
    
            },
    
            "metricsSpec" : [
    
              {
    
                "type" : "count",
    
                "name" : "count"
    
              }
    
            ]
    
          },
