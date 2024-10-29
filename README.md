## Test App

This is a simple Proof-of-Concept to visualize Grafana Prometheus data using
Javascript & Ruby

## How to run

- Prequisite: install ruby 3.3.4
- Set `TOKEN` in `app/server.rb` with your Grafana token

- Run the following command to run

```shell
bundle install

bundle exec ruby app/server.rb
```

- Go to http://localhost:4567/ to view the result
