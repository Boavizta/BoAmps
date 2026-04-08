import mkdocs_gen_files

with open("../README.md") as f:
    content = f.read()
    with mkdocs_gen_files.open("index.md", "w") as f:
        f.write(content)

    mkdocs_gen_files.set_edit_path("index.md", "../README.md")
