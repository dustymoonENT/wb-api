FROM elixir:1.10.4
WORKDIR /app
RUN mix local.hex --force

RUN mix local.rebar --force


RUN wget -q https://github.com/phoenixframework/archives/raw/master/phx_new.ez && mix archive.install --force phx_new.ez

EXPOSE 4000

