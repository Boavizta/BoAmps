import mkdocs_gen_files
from pathlib import Path

with open("../README.md") as f:
    content = f.read()
with mkdocs_gen_files.open("index.md", "w") as f:
    f.write(content)

mkdocs_gen_files.set_edit_path("index.md", "../README.md")

for src in Path("../Resources").iterdir():
    with open(src, "rb") as f_in:
        with mkdocs_gen_files.open(f"Resources/{src.name}", "wb") as f_out:
            f_out.write(f_in.read())
