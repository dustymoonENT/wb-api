FROM elixir:1.10.4

RUN mix local.hex --force

RUN mix local.rebar --force

RUN wget -q https://github.com/phoenixframework/archives/raw/master/phx_new.ez && mix archive.install --force phx_new.ez
COPY . /app
WORKDIR /app
EXPOSE 80
RUN mix do deps.get, deps.compile, compile
CMD ["./prod_run.sh"]
