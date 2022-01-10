$ErrorActionPreference = 'stop'
$RoleName = (New-Guid).Guid
$StepFunctionName = (New-Guid).Guid

Describe 'AWS Step Functions Tests' {
  It 'Should create an AWS IAM Role for AWS Step Functions' {
    {
      $Params = @{
        RoleName = $RoleName
        AssumeRolePolicyDocument = @'
          {
            "Version": "2012-10-17",
            "Statement": [
              {
                "Sid": "",
                "Effect": "Allow",
                "Principal": {
                  "Service": "states.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
              }
            ]
          }
'@
      }
      New-IAMRole @Params
      $SFNDefaultPolicy = Get-IAMPolicyList | ? PolicyName -eq AWSLambdaRole
      Register-IAMRolePolicy -RoleName $RoleName -PolicyArn $SFNDefaultPolicy[0].Arn
    }
  }

  It 'Should create a Step Functions state machine' {
    { New-SFNStateMachine -Definition '{ }' -Name (New-Guid).Guid -RoleArn  } | Should -Not -Throw
  }

  It 'Should delete a Step Functions state machine' {
    { Remove-SFNStateMachine -StateMachineArn -Force  } | Should -Not -Throw
  }

  It 'Should delete the Step Functions AWS IAM role' {
    { Remove-IAMRole -RoleName $RoleName -Force } | Should -Not -Throw
  }
}
