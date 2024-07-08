resource "aws_lb" "alb" {
    name = var.lb_name
    internal = false
    load_balancer_type = var.lb_type
    security_groups = var.lb_sg
    subnets = var.lb_subnets
}

resource "aws_lb_listener" "http_listener" {
    load_balancer_arn = aws_lb.alb.arn
    port = var.http_listener_port
    protocol = "HTTP"

    default_action {
        type = "redirect"
        redirect {
            port = "443"
            protocol = "HTTPS"
            host = var.host_name
            path = "/"
            query = ""
            status_code = "HTTP_301"  # 301 Redirect
        }
    }
}

resource "aws_lb_listener" "https_listener" {
    load_balancer_arn = aws_lb.alb.arn
    port = var.https_listener_port
    protocol = "HTTPS"
    ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
    certificate_arn = data.aws_acm_certificate.ACM.arn
    default_action {
        type = "redirect"
        redirect {
            port = "443"
            protocol = "HTTPS"
            host = var.host_name
            path = "/"
            query = ""
            status_code = "HTTP_301"  # 301 Redirect
        }
    }
}

data "aws_acm_certificate" "ACM" {
    domain = var.domain_name
    statuses = ["ISSUED"]
}


resource "aws_lb_listener_rule" "listener_roles_http" {
    for_each = var.listener_http_roles

    listener_arn = aws_lb_listener.http_listener.arn
    priority = each.value.priority
    action {
        type = "forward"
        target_group_arn = each.value.target_group_arn
    }

    condition {
        path_pattern {
            values = each.value.path_pattern
        }
    }
}

resource "aws_lb_listener_rule" "listener_roles_https" {
    for_each = var.listener_https_roles

    listener_arn = aws_lb_listener.https_listener.arn
    priority = each.value.priority
    action {
        type = "forward"
        target_group_arn = each.value.target_group_arn
    }

    condition {
        path_pattern {
            values = each.value.path_pattern
        }
    }
}