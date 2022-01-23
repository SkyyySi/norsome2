#!/usr/bin/env python3
import os, sys
import subprocess
from typing import Any

#playerctl metadata --format '{ playerName = [[{{ playerName }}]], position = [[{{ position }}]], status = [[{{ status }}]], volume = [[{{ volume }}]], album = [[{{ album }}]], artist = [[{{ artist }}]], title = [[{{ title }}]] }'

def python_dict_to_lua_table(dictionary: dict[str, Any], block_depth: int=0, outstr: str=""):
	outstr += "{"
	for key in dictionary.keys():
		outstr += key + " = "
		if isinstance(dictionary[key], dict):
			python_dict_to_lua_table(dictionary[key], block_depth + 1, outstr)
			return
		outstr += "[[" + dictionary[key] + "]], "
	if block_depth == 0:
		outstr += ","
	outstr += "}"
	print(outstr)


def parse_playerctl_to_dict() -> dict[str, str]:
	metadata = {
		"playerName": "",
		"position": "",
		"status": "",
		"volume": "",
		"album": "",
		"artist": "",
		"title": ""
	}

	for key in metadata.keys():
		new_key = subprocess.run(["playerctl", "metadata", "--format", r"{{ "+key+r" }}"], stdout=subprocess.PIPE).stdout
		metadata[key] = new_key.decode().replace("\n", "")

	return metadata


def main(argv: list[str]):
	print(parse_playerctl_to_dict())


if __name__ == '__main__':
	#main(sys.argv[1:])
	python_dict_to_lua_table({
		"foo": "bar",
		"biz": "baz",
		"hello": {
			"from": "the",
			"other": "side"
		}
	})
