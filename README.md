# AsyncLetBinding
Async let을 통한 Concurrent image download, 단순 async함수 호출을 통한 serial image download 비교 

## Serial Download
기존 async함수만을 사용한 호출은 Serial하게 동작하기 때문에 상대적으로 속도가 느립니다.

![Simulator Screen Recording - iPhone 14 Pro - 2023-03-09 at 18 35 10](https://user-images.githubusercontent.com/39371835/224049499-bba4468e-e835-49e6-a394-3e93a3f8f0c4.gif)

## Concurrent Download
이때, Concurrent 실행을 가장 간단하게 할 수 있는 Swift Concurrency 지원 요소는 __async let을__ 사용하는 것입니다. 
이를 통해 실제 데이터가 쓰이기 직전까지 parent task는 structured programming의 원칙을 따라 다음 statement를 실행하게 됩니다.

![Simulator Screen Recording - iPhone 14 Pro - 2023-03-09 at 19 14 32](https://user-images.githubusercontent.com/39371835/224049843-9f49c267-562b-48d9-bb6b-9d11c274d548.gif)

## 관련 article
https://yudonlee.tistory.com/42
