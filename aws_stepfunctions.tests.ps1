Describe 'AWS Step Functions Tests' {
  BeforeAll {
    $ErrorActionPreference = 'stop'
    $RoleName = (New-Guid).Guid
    $StepFunctionName = (New-Guid).Guid
  }

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
    } | Should -Not -Throw
  }

  It 'Should throw an exception when creating an invalid Step Functions state machine' {
    { 
      $IAMRole = Get-IAMRole $RoleName
      New-SFNStateMachine -Definition '{ }' -Name $StepFunctionName -RoleArn $IAMRole.Arn } | Should -Throw
  }

  It 'Should successfully create a Step Functions state machine' {
    { 
      $IAMRole = Get-IAMRole $RoleName
      $StateMachine = @'
{
  "StartAt": "Step1",
  "States": {
    "Step1": {
      "Type": "Pass",
      "End": true
    }
  }
}
'@
      New-SFNStateMachine -Definition $StateMachine -Name $StepFunctionName -RoleArn $IAMRole.Arn } | Should -Not -Throw
  }

  It 'Should delete a Step Functions state machine' {
    { 
      $StepFunction = Get-SFNStateMachineList | ? Name -eq $StepFunctionName
      Remove-SFNStateMachine -StateMachineArn $StepFunction[0].StateMachineArn -Force  } | Should -Not -Throw
  }

  It 'Should delete the Step Functions AWS IAM role' {
    { 
      $AttachedPolicyList = Get-IAMAttachedRolePolicyList -RoleName $RoleName
      foreach ($AttachedPolicy in $AttachedPolicyList) {
        Unregister-IAMRolePolicy -RoleName $RoleName -PolicyArn $AttachedPolicy.PolicyArn
      }
      Remove-IAMRole -RoleName $RoleName -Force
    } | Should -Not -Throw
  }
}
