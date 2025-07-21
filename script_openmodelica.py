from OMPython import OMCSessionZMQ
from pathlib import Path
import shutil
import sys

def get_path():
    current_dir = Path(__file__).parent
    settings_file = current_dir / 'settings.txt'
    with settings_file.open('r') as f:
        destiny_path = f.readline().strip()
        return destiny_path


def joink_mo():
    mo = sys.argv[1]  # "*.mo"
    print("clone -> file is:", mo)
    return mo

def get_mo_file(path):
    omc = OMCSessionZMQ()
    omc.sendExpression(f'loadFile("{path}")')
    models = omc.sendExpression("getClassNames()")
    model = [m for m in models if omc.sendExpression(f'isModel({m})')][0]
    print("Got model name:", model)
    print("Got path:", path)
    return model, omc

def export_model_to_fmu(mo_file_path: Path, model_name: str, omc) -> Path:
    # Export the model to FMU
    print("building fmu with model:", model_name)
    omc.sendExpression(f'buildModelFMU("{model_name}", version="2.0", fmuType="cs")')
    fmu_file_path = Path(f"{model_name}.fmu")
    print("new fmu at:", mo_file_path)
    file_list = [Path(f'{model_name}.log'),Path(f'{model_name}_FMU.libs'),Path(f'{model_name}_FMU.log'),Path(f'{model_name}_FMU.makefile'),Path(f'{model_name}_info.json')]
    for i in file_list:
        i.unlink()
    print("deleted extra files:", file_list)
    return fmu_file_path

def move_fmu(mo_file:Path, destiny_p:str):
    print("moving fmu to:",destiny_p)
    shutil.move(mo_file, destiny_p)

def pipeline():
    destiny = get_path()
    mo_file = joink_mo()
    model, omc = get_mo_file(mo_file)
    fmu_path = export_model_to_fmu(mo_file, model, omc)
    move_fmu(fmu_path, f"{destiny}{model}.fmu")

pipeline()
