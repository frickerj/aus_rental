terraform {
  cloud {
    organization = "aus-rental"

    workspaces {
      name = "aus-rental"
    }
  }
}
