let

  region = "us-east-1";
  accessKeyId = "djwhitt";

  ec2 =
    { resources, ... }:
    { deployment.targetEnv = "ec2";
      deployment.ec2.accessKeyId = accessKeyId;
      deployment.ec2.region = region;
      deployment.ec2.instanceType = "t2.small";
      deployment.ec2.keyPair = resources.ec2KeyPairs.my-key-pair;
      deployment.ec2.subnetId = "subnet-51184226";
      deployment.ec2.securityGroupIds = [ "sg-c803dbb1" ];
      deployment.ec2.associatePublicIpAddress = true;
    };

in
{ server = ec2;
  resources.ec2KeyPairs.my-key-pair = { inherit region accessKeyId; };
}
