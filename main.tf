module "networking" {
  source = "./modules/networking"

  vpc_cidr                  = var.vpc_cidr
  public_subnets_cidr       = var.public_subnets_cidr
  private_app_subnets_cidr  = var.private_app_subnets_cidr
  private_data_subnets_cidr = var.private_data_subnets_cidr
  name_prefix               = local.name_prefix
  tags                      = local.common_tags
}

module "database" {
  source                  = "./modules/database"
  depends_on              = [module.networking]

  vpc_id                  = module.networking.vpc_id
  subnet_ids              = module.networking.private_data_subnet_ids
  allowed_security_groups = [module.compute.security_group_id]
  db_name                 = "wordpressdb"
  db_username             = "admin"
  name_prefix             = local.name_prefix
  tags                    = local.common_tags
}

module "storage" {
  source                  = "./modules/storage"
  depends_on              = [module.networking]

  vpc_id                  = module.networking.vpc_id
  subnet_ids              = module.networking.private_app_subnet_ids
  allowed_security_groups = [module.compute.security_group_id]
  name_prefix             = local.name_prefix
  tags                    = local.common_tags
}

module "alb" {
  source              = "./modules/alb"
  depends_on          = [module.networking]

  vpc_id              = module.networking.vpc_id
  public_subnet_ids   = module.networking.public_subnet_ids
  name_prefix         = local.name_prefix
  tags                = local.common_tags
}

module "compute" {
  source                = "./modules/compute"
  
  vpc_id                = module.networking.vpc_id
  subnet_ids            = module.networking.private_app_subnet_ids
  target_group_arn      = module.alb.target_group_arn
  alb_security_group_id = module.alb.security_group_id
  instance_type         = var.instance_type
  key_name              = var.key_name
  name_prefix           = local.name_prefix
  tags                  = local.common_tags
  secret_arn            = module.database.secret_arn

  user_data = base64encode(templatefile("${path.module}/install_wordpress.sh", {
    efs_id     = module.storage.file_system_id
    db_host    = module.database.cluster_endpoint
    db_name    = "wordpressdb"
    db_user    = "admin"
    secret_arn = module.database.secret_arn
    region     = var.region
  }))
}
