"""A sample filter, to show that ade's editable install picks up edits."""


def _sample_filter(name: str) -> str:
    return "Hello, " + name


class FilterModule:
    """Filters for myorg.tools."""

    def filters(self):
        return {"sample_filter": _sample_filter}
