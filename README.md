# beemsa
팀 BeeMSA 팀프로젝트 
주제이름: MSA기반 외신뉴스 서비스 
이 깃허브는 팀프로젝트 ci /cd 용으로 만들었습니다. 
프로젝트 끝나면 지울수도 냅둘수도 있으니 프로젝트 끝나면 
소스들은 각자 알아서 챙겨두세요~
  
폴더 구조  
C:  
│  .gitignore  
│  .terraform.lock.hcl  
│  main.tf  
│  README.md  
│  variable.tf  
│  
└─modules  
    ├─autoscaling  
    ├─codebuild  
    ├─codepipeline  
    ├─ecr  
    ├─ecs  
    ├─iam  
    ├─lb  
    ├─route53  
    ├─s3  
    ├─securityGroup  
    ├─targetGroup  
    └─vpc  
  
모듈별 설명  
vpc - vpc, igw, nat, 서브넷, 라우팅테이블 설정  
securityGroup - ALB 보안그룹, ECS 보안그룹 설정  
iam - ECS 역할/정책, CICD 역할/정책 설정  
lb - ALB, 리스너 설정  
route53 - 호스팅 zone, record 설정 => ALB 연결  
targetGroup - 타겟 그룹 설정 => ALB 연결  
ecr - ECR 불러오기  
ecs - 클러스터, 태스크 정의, 서비스 설정  
autoscaling - ECS 오토스케일링 설정(타겟추적)  
s3 - cicd용 버켓 설정  
codebuild - 코드 빌드 설정정  
codepipeline - 코드 파이프라인 설정(ECS 배포)  
