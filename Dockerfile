FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV APP_ENV=production
ENV COMPOSER_ALLOW_SUPERUSER=1

# --- Install PHP 8.4 from Ondřej Surý's PPA ---
RUN apt-get update && apt-get install -y software-properties-common curl gnupg \
 && add-apt-repository ppa:ondrej/php -y \
 && apt-get update && apt-get install -y \
    php8.4 php8.4-cli php8.4-common php8.4-mbstring php8.4-xml php8.4-pgsql php8.4-zip php8.4-gd php8.4-bcmath php8.4-curl php8.4-intl php8.4-readline php8.4-tokenizer \
    git unzip composer nodejs npm \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# Copy project files
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Build front-end
RUN npm install && npm run prod --workspace=v1 && npm run build --workspace=v2

# Fix permissions
RUN chmod -R 775 storage bootstrap/cache && chown -R www-data:www-data storage bootstrap/cache

EXPOSE 8080
CMD ["php8.4", "artisan", "serve", "--host=0.0.0.0", "--port=8080"]
