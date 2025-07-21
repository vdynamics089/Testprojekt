from OMPython import OMCSessionZMQ
from pathlib import Path
import shutil
import sys
import requests

def get_paths():
    current_dir = Path(__file__).parent
    settings_file = current_dir / 'settings.txt'
    with settings_file.open('r') as f:
        destiny_path = f.readline().strip()
        local_p = f.readline().strip()
        return destiny_path, local_p


def joink_mo(local, no_clone: bool):
    prefix = "https://raw.githubusercontent.com/vdynamics089/"
    suffix = sys.argv[1]  # "TestProjekt/main/*.mo"
    url = f"{prefix}{suffix}"
    file = suffix.split("/")[-1]
    if no_clone:
        response = requests.get(url)
        local_path = f"{local}{file}"
        if response.status_code == 200:
            with open(local_path, 'wb') as f:
                f.write(response.content)
            print(f"File saved to {local_path}")
        else:
            print(f"Failed to download file: {response.status_code}")
    else:
        local_path = file
    return local_path

def get_mo_file(path) -> Path:
    omc = OMCSessionZMQ()
    omc.sendExpression(f'loadFile("{path}")')
    print(omc.sendExpression("getClassNames()"))
    models = omc.sendExpression("getClassNames()")
    model = [m for m in models if omc.sendExpression(f'isModel({m})')][0]
    print("Got model name:", model)
    print("Got path:", path)
    return path, model, omc

def export_model_to_fmu(mo_file_path: Path, model_name: str, omc, local) -> Path:
    # Export the model to FMU
    print("building fmu with model:", model_name)
    omc.sendExpression(f'buildModelFMU({model_name})')
    mo_file_path = Path(f"{model_name}.fmu")
    print("new fmu at:", mo_file_path)
    file_list = [Path(f'{model_name}.log'),Path(f'{model_name}_FMU.libs'),Path(f'{model_name}_FMU.log'),Path(f'{model_name}_FMU.makefile'),Path(f'{model_name}_info.json'), Path(local)]
    for i in file_list:
        i.unlink()
    print("deleted extra files:", file_list)
    return mo_file_path

def move_fmu(mo_file:Path, destiny_p:str):
    print("moving fmu to:",destiny_p)
    shutil.move(mo_file, destiny_p)

def pipeline():
    destiny, local = get_paths()
    local_path = joink_mo(local, False)
    mo_file, model, omc = get_mo_file(local_path)
    mo_path = export_model_to_fmu(mo_file, model, omc, local_path)
    move_fmu(mo_path, f"{destiny}{model}.fmu")

pipeline()

