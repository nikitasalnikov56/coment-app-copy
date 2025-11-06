# import os

# # Папка проекта ('.' = текущая)
# root_dir = "lib"

# # Файл, куда всё записывать
# output_file = "project_dump.txt"

# with open(output_file, "w", encoding="utf-8") as out:
#     for folder, _, files in os.walk(root_dir):
#         for file in files:
#             filepath = os.path.join(folder, file)
#             relpath = os.path.relpath(filepath, root_dir)

#             # пропустить сам output_file, чтобы не зациклиться
#             if relpath == output_file:
#                 continue

#             out.write(f"\n\n=== {relpath} ===\n\n")
#             try:
#                 with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
#                     out.write(f.read())
#             except Exception as e:
#                 out.write(f"[Не удалось прочитать файл: {e}]")



# import os

# root_dir = "lib"
# output_file = "project_dump.txt"

# count = 0

# with open(output_file, "w", encoding="utf-8") as out:
#     for folder, _, files in os.walk(root_dir):
#         for file in files:
#             filepath = os.path.join(folder, file)
#             relpath = os.path.relpath(filepath, root_dir)

#             if relpath == output_file:  # пропустить сам файл дампа
#                 continue

#             if any(skip in relpath for skip in [".git", "node_modules", "build"]):
#                 continue

#             out.write(f"\n{relpath}\n")
#             out.write("-" * len(relpath) + "\n")

#             try:
#                 with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
#                     out.write(f.read())
#             except Exception as e:
#                 out.write(f"[Не удалось прочитать файл: {e}]")

#             out.write("\n\n")
#             count += 1

#     out.write(f"\n\n=== Всего файлов: {count} ===\n")
import os

# что включить в дамп
# include = [
#     "lib",                # вся папка src
#     "android",                # вся папка android
#     "assets",                # вся папка assets
#     "l10n.yaml", # файл
#     "flutter_native_splash.yaml", # файл
#     "pubspec.yaml", # файл
#     "firebase.json",       # файл
# ]

# output_file = "project_dump_final.txt"
# count = 0

# def dump_file(filepath, out):
#     global count
#     relpath = os.path.relpath(filepath, ".")
#     out.write(f"\n{relpath}\n")
#     out.write("-" * len(relpath) + "\n")

#     try:
#         with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
#             out.write(f.read())
#     except Exception as e:
#         out.write(f"[Не удалось прочитать файл: {e}]")

#     out.write("\n\n")
#     count += 1


# with open(output_file, "w", encoding="utf-8") as out:
#     for item in include:
#         if os.path.isdir(item):
#             # обойти все файлы в папке
#             for folder, _, files in os.walk(item):
#                 for file in files:
#                     filepath = os.path.join(folder, file)
#                     dump_file(filepath, out)
#         elif os.path.isfile(item):
#             dump_file(item, out)
#         else:
#             out.write(f"\n[Пропущено: {item} (не найдено)]\n")

#     out.write(f"\n\n=== Всего файлов: {count} ===\n")

include = [
    "lib",                # вся папка src

]

output_file = "lib1.txt"
count = 0

def dump_file(filepath, out):
    global count
    relpath = os.path.relpath(filepath, ".")
    out.write(f"\n{relpath}\n")
    out.write("-" * len(relpath) + "\n")

    try:
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            out.write(f.read())
    except Exception as e:
        out.write(f"[Не удалось прочитать файл: {e}]")

    out.write("\n\n")
    count += 1


with open(output_file, "w", encoding="utf-8") as out:
    for item in include:
        if os.path.isdir(item):
            # обойти все файлы в папке
            for folder, _, files in os.walk(item):
                for file in files:
                    filepath = os.path.join(folder, file)
                    dump_file(filepath, out)
        elif os.path.isfile(item):
            dump_file(item, out)
        else:
            out.write(f"\n[Пропущено: {item} (не найдено)]\n")

    out.write(f"\n\n=== Всего файлов: {count} ===\n")