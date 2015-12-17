# Do not include default locale in generated URLs
RoutingFilter::Locale.include_default_locale = false

# Then if the default locale is :de
# products_path(:locale => 'de') => /products
# products_path(:locale => 'en') => /en/products