alias ExCommerce.Repo
alias ExCommerce.Marketplaces
alias ExCommerce.Marketplaces.{Shop, Brand, BrandUser}
alias ExCommerce.Offerings

alias ExCommerce.Offerings.{
  Catalogue,
  CatalogueCategory,
  CatalogueItem,
  CatalogueItemOption,
  CatalogueItemOptionGroup,
  CatalogueItemVariant
}

alias ExCommerce.Uploads
alias ExCommerce.Uploads.{Photo}

require Logger

:ok = Logger.configure(level: :info)
