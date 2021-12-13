# kyverno-ingress-job

Demonstration policy to show that a generate policy can be leveraged to pass key details such as Ingress hostname to a downstream batch job that can carry out actions with 3rd party API's for example to schedule web vulnerability scan.
Each time the ingress manifest is altered, the job should be rerun.


- You could write idempotent API stories!
    - eg with postman and execute headless with newman
    - with ansible localhost
    - Full language such as Golang, Rust or other compiled type (run Lean), plus can add unit testing easily.