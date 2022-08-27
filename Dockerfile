FROM elixir:1.10.4-slim

WORKDIR /app

RUN useradd --create-home elixir \
  && mkdir -p /mix && chown elixir:elixir -R /mix /app

RUN mix local.hex --force && mix local.rebar --force

ARG MIX_ENV="prod"
ENV MIX_ENV="${MIX_ENV}" \
    USER="elixir"

COPY --chown=elixir:elixir mix.* ./

RUN if [ "${MIX_ENV}" = "dev" ]; then \
  mix deps.get; else mix deps.get --only "${MIX_ENV}"; fi

COPY --chown=elixir:elixir config/config.exs config/"${MIX_ENV}"*.exs config/
RUN mix deps.compile

COPY --chown=elixir:elixir . .

#RUN mix compile

EXPOSE 80

CMD ["./prod_run.sh"]
