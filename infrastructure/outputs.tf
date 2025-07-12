output "api_url" {
  description = "URL to access the Vehicle Catalog API"
  value       = "http://${module.alb.alb_dns_name}"
}