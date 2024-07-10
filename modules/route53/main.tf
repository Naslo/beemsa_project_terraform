data "aws_route53_zone" "hyperkittys_shop" {
    name = var.route53_zone_name
}

resource "aws_route53_record" "record_alb" {
    zone_id = data.aws_route53_zone.hyperkittys_shop.zone_id
    name = var.route53_record_name
    type = "A"

    alias {
        name = var.alb_dns_name
        zone_id = var.alb_zone_id
        evaluate_target_health = true
    }
}