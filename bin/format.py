import json
import logging
import os
from pathlib import Path

import yaml
from black import format_str, FileMode
from cfn_flip import to_json, to_yaml

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

CURRENT_PATH = Path(os.getcwd())


def format_templates():
    """ Subjectively formats and sorts keys of CloudFormation templates written in YAML."""
    for subdir, dirs, files in os.walk((CURRENT_PATH.parent)):
        for file in files:
            if file.endswith("template.yaml") or file.endswith("template.yml"):
                with open(os.path.join(subdir, file), "r+") as template:
                    try:
                        formatted_json_template = to_json(template.read())
                        formatted_template = to_yaml(
                            json.dumps(
                                json.loads(formatted_json_template),
                                indent=4,
                                sort_keys=True,
                            ),
                            clean_up=True
                        )
                        template.seek(0)
                        template.write(formatted_template)
                        template.truncate()
                    except json.decoder.JSONDecodeError as e:
                        logger.error("Failed to format %s" % os.path.join(subdir, file))
                        raise e

                    logger.info("Formatted %s" % os.path.join(subdir, file))


format_templates()
