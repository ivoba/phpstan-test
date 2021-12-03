# phpstan-test
For: https://stackoverflow.com/questions/69851516/phpstan-and-doctrine-id-is-never-written-only-read?noredirect=1#comment123480939_69851516

For: https://github.com/symfony/symfony/issues/44426

run:

    ./docker.sh

in container run:

    composer install
    vendor/bin/simple-phpunit
