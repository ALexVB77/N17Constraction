
import os 
import collections
from posixpath import splitext
from typing import Dict


ObjectInfo = collections.namedtuple('ObjectInfo', 'type id name')
MapEntry = collections.namedtuple('MapEntry', 'type name old_id new_id al_file has_new_id')

mapping_filename = './mapping.csv'
mapping_ed_filename = './Mapping-edited.csv'

extension_folder = ['../../AL/GeneralExt/', '../../AL/BankStatement/', '../../AL/ExcelBufferModExt/', '../../AL/WhseMgtExt/']
#extension_folder = ['../../AL/GeneralExt/']

ranges = {
    'table': (70000, 70239)
    ,'report' : (70000,70399)
    , 'codeunit' : (70000, 70109)
    , 'page' : (50010, 50609, 70000, 70299)
    , 'xmlport' : (70000, 70299)
    , 'query' : (50000, 50099)
    ,
}


class Renumerator:
    
    allowed_types = ['table', 'report', 'codeunit', 'page', 'xmlport', 'query', 'tableextension', 'pageextension', 'enum']

    alt_type_map = {
        'tableextension' : 'table'
        , 'pageextension' : 'page'
        ,
    }

    def __init__(self, folders: list, ranges: dict) -> None:
        self.last_id_fwd = {}
        self.last_id_bwd = {}
        self.ext_folders: list = folders
        self.licensed_ranges: dict = ranges
        self.license_assignment_objects = self.licensed_ranges.keys()
        self.used_object_id = {}
        self.renum_map = {}

    def renumerate(self, mapping_filename: str = None) -> None:
        if mapping_filename: 
            self.create_mapping_from_file(mapping_filename)
        else:
            self.create_mapping_file()
        assert self.renum_map
        for me in self.renum_map.values():
            self.__deep_renum(me)

    def create_mapping_file(self) -> None:
        is_general_ext_folder = True
        obj_type: str
        for folder in self.ext_folders:
            al_files = self.__get_list_of_files(folder)
            temp_map = {}
            for al_file in al_files:
                obj_info = self.__get_object_info(al_file)
                if not obj_info:
                    continue
                uid = self.__get_uid(obj_info.type, obj_info.id)
                if obj_info.type in self.license_assignment_objects:
                    new_id = 0
                    if is_general_ext_folder and self.__check_range(obj_info.type, obj_info.id):
                        self.used_object_id[uid] = 1
                        new_id = obj_info.id
                else: 
                    new_id = obj_info.id
                    if obj_type := self.alt_type_map.get(obj_info.type, None):
                        if self.__check_range(obj_type, obj_info.id):
                            raise ValueError(f'{obj_info.type} {obj_info.id} in license assingnment range!')
                temp_map[uid] = MapEntry(type=obj_info.type, name=obj_info.name, old_id=obj_info.id, new_id=new_id, al_file=al_file, has_new_id=new_id != obj_info.id)
            me: MapEntry
            for me in temp_map.values():
                new_id = me.new_id
                if not new_id:
                    new_id = self.__get_next_id(me.type, me.old_id, is_general_ext_folder)
                    uid = self.__get_uid(me.type, new_id)
                    self.used_object_id[uid] = 1
                self.__add_to_map(me.type, me.old_id, me.name, new_id, me.al_file, new_id != me.old_id )
            is_general_ext_folder = False
        self.__export_map(mapping_filename)

    def __read_mapping_file(self, map_file_name: str) -> Dict:
        temp_map = {}
        with open(map_file_name, 'r', encoding='utf8') as fi:
            for k, ln in enumerate(fi):
                if k == 0: continue
                words = ln.split(';')
                object_type = words[0].lower()
                object_curr_id = int(words[1])
                #if object_curr_id == 99100:
                #    object_curr_id = 99100
                object_new_id = int(words[3])
                if words[4].lower() == 'true':
                    has_new_id = True
                elif words[4].lower() == 'false':
                    has_new_id = False
                if (has_new_id and (object_curr_id == object_new_id)) or (not has_new_id and (object_curr_id != object_new_id)):
                    err = f'Wrong has new id value {object_new_id} and {object_curr_id}'
                    raise ValueError(err)
                if object_curr_id == object_new_id: continue
                temp_map[self.__get_uid(object_type, object_curr_id)] = \
                    MapEntry(type = object_type, name = '', \
                        old_id = object_curr_id, new_id = object_new_id, \
                        al_file = '', has_new_id = True)
        return temp_map

    def create_mapping_from_file(self, map_file_name: str) -> None:
        me: MapEntry
        self.renum_map = {}
        temp_map = self.__read_mapping_file(map_file_name)
        if not temp_map: return
        for folder in self.ext_folders:
            al_files = self.__get_list_of_files(folder)
            for al_file in al_files:
                obj_info = self.__get_object_info(al_file)
                if not obj_info: continue
                uid = self.__get_uid(obj_info.type, obj_info.id)
                me = temp_map.get(uid)
                if not me: continue
                self.__add_to_map(me.type, \
                    me.old_id, \
                    obj_info.name, \
                    me.new_id, \
                    al_file, \
                    True )

    def __deep_renum(self, map_entry: MapEntry) -> None:
        def get_new_filename(map_entry: MapEntry) -> str:
            sfn = f'{map_entry.type[0].upper()}{map_entry.type[1:]}{map_entry.new_id}.{"".join([s for s in map_entry.name if s.isalpha() or s.isdigit()])}.al'
            dirname = os.path.dirname(map_entry.al_file)
            return os.path.join(dirname, sfn)
        if map_entry.old_id == map_entry.new_id:
            return
        with open(map_entry.al_file, 'r', encoding='utf8') as fi:
            lines = fi.readlines()
        os.remove(map_entry.al_file)
        for n, ln in enumerate(lines):
            if not ln.strip():
                continue
            if ln.split()[0].lower() in self.allowed_types:
                lines[n] = ln.replace(str(map_entry.old_id), str(map_entry.new_id))
                break
        with open(get_new_filename(map_entry), 'w', encoding='utf8') as fo:
            for ln in lines:
                fo.write(ln)

    def __get_next_id(self, object_type: str, current_object_id: int, forward = True) -> int:
        return (self.__get_next_id_fwd if forward else self.__get_next_id_bwd) (object_type, current_object_id)

    def __get_next_id_fwd(self, object_type: str, current_object_id: int) -> int:
        new_id = None
        id_range: tuple = self.licensed_ranges.get(object_type)
        last_used_id = self.last_id_fwd.get(object_type, 0)
        if not last_used_id: 
            last_used_id = self.__incid(object_type, id_range[0], True)
        else:
            last_used_id = self.__incid(object_type, last_used_id)
        id_ranges_count = len(id_range) // 2
        for rng in range(id_ranges_count):
            start_id = rng * id_ranges_count
            end_id = start_id + 1
            if id_range[start_id] > last_used_id:
                last_used_id = id_range[start_id]
                last_used_id = self.__incid(object_type, last_used_id, True)
            if last_used_id in range(id_range[start_id], id_range[end_id] + 1):
                new_id = last_used_id
                break
        if not new_id:
            raise ValueError(f"Out of range for new object id of '{object_type}' type")
        if current_object_id != new_id:
            self.last_id_fwd[object_type] = new_id
        return new_id

    def __get_next_id_bwd(self, object_type: str, current_object_id: int) -> int:
        new_id = None
        id_range: tuple = self.licensed_ranges.get(object_type)
        last_used_id = self.last_id_bwd.get(object_type, 0)
        if not last_used_id: 
            last_used_id = self.__decid(object_type, id_range[-1], True)
        else:
            last_used_id = self.__decid(object_type, last_used_id)
        id_ranges_count = len(id_range) // 2
        rev = reversed(range(id_ranges_count))
        for rng in rev:
            start_id = rng * id_ranges_count
            end_id = start_id + 1
            if id_range[end_id] < last_used_id:
                last_used_id = id_range[end_id]
                last_used_id = self.__decid(object_type, last_used_id, True)
            if last_used_id in range(id_range[start_id], id_range[end_id] + 1):
                new_id = last_used_id
                break
        if not new_id:
            raise ValueError(f"Out of range for new object id of '{object_type}' type")    
        self.last_id_bwd[object_type] = new_id
        return new_id

    def __incid(self, object_type: str, object_id: int, do_not_increase_before: bool = False) -> int:
        if not do_not_increase_before:
            object_id += 1
        while self.used_object_id.get(self.__get_uid(object_type, object_id)):
            object_id += 1
        return object_id

    def __decid(self, object_type: str, object_id: int, do_not_decrease_before: bool = False) -> int:
        if not do_not_decrease_before:
            object_id -= 1
        while self.used_object_id.get(self.__get_uid(object_type, object_id)):
            object_id -= 1
        return object_id

    def __add_to_map(self, object_type: str, object_old_id: int, object_name: str, object_new_id: int, al_filename: str, has_new_id: bool) -> None:
        self.renum_map[self.__get_uid(object_type, object_old_id)] = \
            MapEntry(type = object_type, name = object_name, old_id=object_old_id, new_id=object_new_id, al_file = al_filename, has_new_id=has_new_id)

    def __get_list_of_files(self, basedir: str) -> list:
        list_of_files = []
        diritems = os.listdir(basedir)
        for item in diritems:
            full_path = os.path.join(basedir, item)
            if os.path.isdir(full_path):
                list_of_files = list_of_files + self.__get_list_of_files(full_path)
            else:
                if os.path.splitext(full_path)[1].lower() == '.al':
                    list_of_files.append(full_path)
        return list_of_files

    def __get_object_info(self, al_filename: str) -> ObjectInfo:
        with open(al_filename, 'r', encoding='utf8') as fi:
            for code_line in fi:
                if not code_line:
                    continue
                words = code_line.split(' ', 2)
                object_type = words[0].lower()
                if object_type in self.allowed_types:
                    return ObjectInfo(type = object_type, id = int(words[1]), name = self.__get_object_name(words[2]))

    def __check_range(self, object_type: str, obj_id: int) -> bool:
        id_range: tuple = self.licensed_ranges.get(object_type)
        id_ranges_count = len(id_range) // 2
        for rng in range(id_ranges_count):
            start_id = rng * id_ranges_count
            end_id = start_id + 1
            if obj_id in range(id_range[start_id], id_range[end_id] + 1):
                return True
        return False        

    def __get_object_name(self, obj_def_line: str) -> str:
        assert obj_def_line
        if obj_def_line.startswith('"'):
            return obj_def_line.split('"', 2)[1]
        else:
            return obj_def_line.split()[0]

    def __export_map(self, filename: str) -> None:
        with open(filename, 'w', encoding='utf8') as fo:        
            me: MapEntry
            fo.write(f'Type;Id;Name;NewId;HasNewId\n')
            for me in self.renum_map.values():
                fo.write(f'{me.type};{me.old_id};{me.name};{me.new_id};{me.has_new_id}\n')

    def __get_uid(self, object_type: str, object_id: int) -> str:
        return(f'{object_type}${object_id}')


def main():
    rn = Renumerator(extension_folder, ranges)
    #rn.create_mapping_file()
    rn.renumerate(mapping_ed_filename)


if __name__ == '__main__':
    main()
