import sys
from typing import List

import click
from click import Context
from localstack.cli import LocalstackCli, LocalstackCliPlugin, console


class SupportCliPlugin(LocalstackCliPlugin):
    name = "support-cli"

    def should_load(self) -> bool:
        return True

    def attach(self, cli: LocalstackCli) -> None:
        group: click.Group = cli.group
        group.add_command(support)


@click.group(name="support", help="Utilities for common LocalStack support tasks")
def support():
    pass


@support.command(name="diagnose", help="Parse and display a diagnose file")
@click.option(
    "-f", "--file", help="Diagnose tar.gz file to analyze", default=""
)
@click.option(
    "-s", "--sections", help="Sections of the diagnose tar.gz file to analyze (e.g., logs)", default=[], multiple=True
)
@click.pass_context
def cmd_support_diagnose(ctx: Context, file: str, sections: List[str]):
    from localstack_support import diagnose

    try:
        diagnose.inspect_diagnose_file(file, sections=sections)
    except Exception as e:
        console.print("Unable to start and register auth proxy: %s" % e)
        ctx.exit(1)
