#!/usr/bin/env python3
import argparse
import difflib
import glob
import re
import sys
from pathlib import Path

from openai import OpenAI


def clean_markdown_fences(text: str) -> str:
	"""
	Remove ```fences``` (e.g., ```jinja) from model output.
	"""
	# Remove starting fence and ending fence 
	text = re.sub(r"^```[^\n]*\n", "", text)
	# Remove ending fence
	text = re.sub(r"\n```$", "", text)
	return text


def main():
	parser = argparse.ArgumentParser(
		description="Mass apply code transformation using OpenAI"
	)
	parser.add_argument(
		"glob_pattern",
		help="Glob pattern for files (e.g., templates/**/*.jinja)",
	)
	parser.add_argument(
		"instruction",
		help="Instruction to transform the code",
	)
	parser.add_argument(
		"--model",
		default="gpt-4.1-mini",
		help="OpenAI model (default: gpt-4o)",
	)
	parser.add_argument(
		"--dry-run",
		action="store_true",
		help="Print diffs but do not overwrite files",
	)
	args = parser.parse_args()

	client = OpenAI()

	files = glob.glob(args.glob_pattern, recursive=True)
	if not files:
		sys.stdout.write(f"No files matched pattern: {args.glob_pattern}\n")
		return

	for file_path in files:
		sys.stdout.write(f"Processing: {file_path}\n")

		with open(file_path, "r", encoding="utf-8") as f:
			original_content = f.read()

		prompt = (
			"You are an expert code refactoring assistant.\n\n"
			f"## Instruction\n{args.instruction}\n\n"
			"Return ONLY the full transformed file content without any Markdown formatting or explanation.\n\n"
			"If no changes are necessary, return an empty string."
			"### Original content below:\n"
			f"{original_content}\n"
		)

		response = client.chat.completions.create(
			model=args.model,
			messages=[
				{
					"role": "system",
					"content": "You transform code files as instructed by the user."
				},
				{
					"role": "user",
					"content": prompt,
				},
			],
			temperature=0,
		)

		transformed = response.choices[0].message.content.strip()
		transformed = transformed.replace("\r\n", "\n")
		transformed = clean_markdown_fences(transformed)
		transformed += "\n"  # Ensure it ends with a newline

		original_content = original_content.strip()
		original_content = original_content.replace("\r\n", "\n")
		original_content += "\n"  # Ensure it ends with a newline

		if transformed == original_content:
			continue  # No change; skip output

		if transformed.strip() == "":
			continue

		diff = difflib.unified_diff(
			original_content.splitlines(),
			transformed.splitlines(),
			fromfile=f"{file_path} (original)",
			tofile=f"{file_path} (transformed)",
			lineterm="",
		)

		sys.stdout.write("\n".join(diff) + "\n")

		if not args.dry_run:
			Path(file_path).write_text(transformed, encoding="utf-8")
			sys.stdout.write(f"\nOverwritten: {file_path}\n")


if __name__ == "__main__":
	main()
