data "template_file" "container_defs" {
  template = "${file("container_definitions.json")}"

  vars {
    name    = "${var.name}"
    env     = "${terraform.env}"
    version = "${var.image_version}"
    tag     = "${var.tag}"
    memory  = "${lookup(var.memory, terraform.env)}"
    cpu     = "${lookup(var.cpu, terraform.env)}"
  }
}

module "main" {
  source  = "egarbi/ecs-service/aws"
  version = "1.0.9"

  name                  = "${var.name}"
  environment           = "${terraform.env}"
  desired_count         = "${lookup(var.desired_count, terraform.env)}"
  cluster               = "${data.terraform_remote_state.vpc.cluster}"
  iam_role              = "${data.terraform_remote_state.vpc.iam_role}"
  vpc_id                = "${data.terraform_remote_state.vpc.vpc_id}"
  zone_id               = "${data.terraform_remote_state.vpc.zone_id}"
  rule_priority         = "${var.priority}"
  alb_listener          = "${data.terraform_remote_state.vpc.alb_listener_arn}"
  alb_zone_id           = "${data.terraform_remote_state.vpc.alb_zone_id}"
  alb_dns_name          = "${data.terraform_remote_state.vpc.alb_dns_name}"
  container_definitions = "${data.template_file.container_defs.rendered}"
}

// If you dont need alarms for you service, ignore the piece of code below
module "alarms" {
  source  = "egarbi/target-group-alarms/aws"
  version = "0.0.3"

  tg_arn_suffix   = "${module.main.target_group_arn_suffix}"
  lb_arn          = "${data.terraform_remote_state.vpc.alb_arn}"
  sns_arn         = "${data.aws_sns_topic.main.arn}"
}
