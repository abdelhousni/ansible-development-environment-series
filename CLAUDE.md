# Working in ansible-development-environment-series

Companion examples for the "Ansible development environment" series on
til.housni.eu (abdelhousni/til, `ansible/*.md`). Each example is
`NN-name/`, with a row in the root README table and in `INDEX.md`. An
example that needs a new tool adds it to the README's "Local lab" table and
to `lab/check.sh`.

## Commits

Commits are authored by the repository owner: check
`git var GIT_AUTHOR_IDENT` before the first commit and expect
`abdelhousni <23284113+abdelhousni@users.noreply.github.com>`. Credit Claude
only with a `Co-Authored-By` trailer, and don't add a `Claude-Session:`
trailer.

Commit messages and pull request titles follow
[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):
`type(scope): summary`, with `type` one of `feat`, `fix`, `docs`, `chore`,
`refactor`, `test` or `ci`, and the example directory, `lab` or `ci` as
the optional scope, for example `feat(04-name): add example 04` or
`fix(lab): check for ansible-navigator`.
