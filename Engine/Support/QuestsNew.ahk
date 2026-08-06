#Requires AutoHotkey v2.0

; ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰
; QUEST CONFIGURATION FILE
; ----------------------------------------------------------------------------------------
; This document encompasses comprehensive information for every quest. Each quest is
; defined by the following attributes:
;   • ID: Unique identifier for the quest.
;   • Name: The designated name of the quest.
;   • Regex: Regular expression utilized for quest identification.
;   • Status: Automation status categorized as either Auto or Manual.
;   • Zone: The specific zone where the quest must be accomplished.
;   • Priority: Level of importance determining the quest's actioning sequence.
; ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰

global QUEST_PRIORITY := Map()
QUEST_PRIORITY.Default := 0


; ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰
; QUEST PRIORITIES
; ----------------------------------------------------------------------------------------
; Modify the settings below to change how quests are prioritized and executed.  Quests are
; initially sorted and executed based on their priority. If multiple quests share the same
; priority, they are then sorted and executed according to their star level, with higher
; star levels being prioritized.
; * Note: Setting the priority to 0 will cause the macro to skip the quest.
; ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰

QUEST_PRIORITY["9"] := 20  ; "Break Diamond Breakables"
QUEST_PRIORITY["14"] := 1  ; "Collect Potions"
QUEST_PRIORITY["15"] := 1  ; "Collect Enchants"
QUEST_PRIORITY["20"] := 20  ; "Hatch Best Egg"
QUEST_PRIORITY["21"] := 10  ; "Break Breakables in Best Area"
QUEST_PRIORITY["31"] := 20  ; "Break Coin Jars"
QUEST_PRIORITY["33"] := 30  ; "Use Flags"
QUEST_PRIORITY["34-1"] := 30  ; "Use Tier 3 Potions"
QUEST_PRIORITY["34-2"] := 30  ; "Use Tier 4 Potions"
QUEST_PRIORITY["34-3"] := 30  ; "Use Tier 5 Potions"
QUEST_PRIORITY["35"] := 5  ; "Eat Fruits"
QUEST_PRIORITY["37"] := 20  ; "Break Coin Jars in Best Area"
QUEST_PRIORITY["38"] := 20  ; "Break Comets in Best Area"
QUEST_PRIORITY["39"] := 3  ; "Break Mini-Chests in Best Area"
QUEST_PRIORITY["40"] := 25  ; "Make Golden Pets from Best Egg"
QUEST_PRIORITY["41"] := 25  ; "Make Rainbow Pets from Best Egg"
QUEST_PRIORITY["42"] := 20  ; "Hatch Rare Pets"
QUEST_PRIORITY["43"] := 20  ; "Break Pinatas in the Best Area"
QUEST_PRIORITY["44"] := 20  ; "Break Lucky Blocks in the Best Area"
QUEST_PRIORITY["66"] := 3  ; "Break Superior Mini-Chests in Best Area"


; ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰
; QUEST PRIORITY OVERRIDES
; ----------------------------------------------------------------------------------------
; The quest overrides below are utilized by the macro and should not be altered by the
; user.
; ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰

; Update the priority if the player does not have VIP.
if (getSetting("HasGamepassVip") == "false")
    QUEST_PRIORITY["9"] := 0  ; "Break Diamond Breakables"

; Update the priority if the player has Super Drops.
if (getSetting("HasGamepassSuperDrops") == "true") {
    QUEST_PRIORITY["14"] := 0  ; "Collect Potions"
    QUEST_PRIORITY["15"] := 0  ; "Collect Enchants"
}


; ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰
; QUEST PROPERTIES
; ----------------------------------------------------------------------------------------
; The quest properties listed below are utilized by the macro and should not be altered by
; the user.
; ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰

global RANK_QUESTS := Map()  ; Initialize a Map object to hold various quest properties.
RANK_QUESTS.Default := Map("Name", "?", "Regex", "", "Status", "Manual", "Zone", "-") ; Set default values for a quest, used when no specific quest is defined.

; ========================================
; Rank 1
; ========================================

; Tier 1
RANK_QUESTS["1_1"] := Map("Name","Break Breakables","Regex","i)break(?!.*diamond).*breakable(?!.*best)","Status","Manual","Zone","-")
RANK_QUESTS["1_2"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["1_3"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")

; Tier 2
RANK_QUESTS["1_4"] := Map("Name","Break Breakables","Regex","i)break(?!.*diamond).*breakable(?!.*best)","Status","Manual","Zone","-")
RANK_QUESTS["1_5"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["1_6"] := Map("Name","Hatch Eggs","Regex","i)hatch(?!.*best).*egg","Status","Manual","Zone","Best")


; ========================================
; Rank 2
; ========================================

; Tier 1
RANK_QUESTS["2_1"] := Map("Name","Break Breakables","Regex","i)break(?!.*diamond).*breakable(?!.*best)","Status","Manual","Zone","-")
RANK_QUESTS["2_2"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["2_3"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")

; Tier 2
RANK_QUESTS["2_4"] := Map("Name","Break Breakables","Regex","i)break(?!.*diamond).*breakable(?!.*best)","Status","Manual","Zone","-")
RANK_QUESTS["2_5"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["2_6"] := Map("Name","Hatch Eggs","Regex","i)hatch(?!.*best).*egg","Status","Manual","Zone","Best")

; Tier 3
RANK_QUESTS["2_7"] := Map("Name","Hatch Pets","Regex","i)hatch(?!.*rare)(?!.*rainb)(?!.*gold)(?!.*ind)(?!.*fuse).*pet","Status","Manual","Zone","-")
RANK_QUESTS["2_8"] := Map("Name","Make Golden Pets","Regex","i)golden(?!.*best)","Status","Manual","Zone","Best")
RANK_QUESTS["2_9"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")


; ========================================
; Rank 3
; ========================================

; Tier 1
RANK_QUESTS["3_1"] := Map("Name","Break Breakables","Regex","i)break(?!.*diamond).*breakable(?!.*best)","Status","Manual","Zone","-")
RANK_QUESTS["3_2"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["3_3"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")

; Tier 2
RANK_QUESTS["3_4"] := Map("Name","Break Breakables","Regex","i)break(?!.*diamond).*breakable(?!.*best)","Status","Manual","Zone","-")
RANK_QUESTS["3_5"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["3_6"] := Map("Name","Hatch Eggs","Regex","i)hatch(?!.*best).*egg","Status","Manual","Zone","Best")

; Tier 3
RANK_QUESTS["3_7"] := Map("Name","Hatch Pets","Regex","i)hatch(?!.*rare)(?!.*rainb)(?!.*gold)(?!.*ind)(?!.*fuse).*pet","Status","Manual","Zone","-")
RANK_QUESTS["3_8"] := Map("Name","Make Golden Pets","Regex","i)golden(?!.*best)","Status","Manual","Zone","Best")
RANK_QUESTS["3_9"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")


; ========================================
; Rank 4
; ========================================

; Tier 1
RANK_QUESTS["4_1"] := Map("Name","Break Breakables","Regex","i)break(?!.*diamond).*breakable(?!.*best)","Status","Manual","Zone","-")
RANK_QUESTS["4_2"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["4_3"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")

; Tier 2
RANK_QUESTS["4_4"] := Map("Name","Break Breakables","Regex","i)break(?!.*diamond).*breakable(?!.*best)","Status","Manual","Zone","-")
RANK_QUESTS["4_5"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["4_6"] := Map("Name","Hatch Eggs","Regex","i)hatch(?!.*best).*egg","Status","Manual","Zone","Best")

; Tier 3
RANK_QUESTS["4_7"] := Map("Name","Hatch Pets","Regex","i)hatch(?!.*rare)(?!.*rainb)(?!.*gold)(?!.*ind)(?!.*fuse).*pet","Status","Manual","Zone","-")
RANK_QUESTS["4_8"] := Map("Name","Make Golden Pets","Regex","i)golden(?!.*best)","Status","Manual","Zone","Best")
RANK_QUESTS["4_9"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")


; ========================================
; Rank 5
; ========================================

; Tier 1
RANK_QUESTS["5_1"] := Map("Name","Break Breakables","Regex","i)break(?!.*diamond).*breakable(?!.*best)","Status","Manual","Zone","-")
RANK_QUESTS["5_2"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["5_3"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")

; Tier 2
RANK_QUESTS["5_4"] := Map("Name","Break Breakables","Regex","i)break(?!.*diamond).*breakable(?!.*best)","Status","Manual","Zone","-")
RANK_QUESTS["5_5"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["5_6"] := Map("Name","Hatch Eggs","Regex","i)hatch(?!.*best).*egg","Status","Manual","Zone","Best")

; Tier 3
RANK_QUESTS["5_7"] := Map("Name","Hatch Pets","Regex","i)hatch(?!.*rare)(?!.*rainb)(?!.*gold)(?!.*ind)(?!.*fuse).*pet","Status","Manual","Zone","-")
RANK_QUESTS["5_8"] := Map("Name","Make Golden Pets","Regex","i)golden(?!.*best)","Status","Manual","Zone","Best")
RANK_QUESTS["5_9"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")

; Tier 4
RANK_QUESTS["5_10"] := Map("Name","Make Rainbow Pets","Regex","i)rainbow(?!.*best)","Status","Manual","Zone","Best")
RANK_QUESTS["5_11"] := Map("Name","Break Mini-Chests","Regex","i)mini.*chest(?!.*best)","Status","Manual","Zone","-")
RANK_QUESTS["5_12"] := Map("Name","Buy Potions","Regex","i)buy.*pot","Status","Manual","Zone","-")

; ========================================
; Rank 6
; ========================================

; Tier 1
RANK_QUESTS["6_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["6_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["6_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["6_4"] := Map("Name","Use Tier 3 Potions","Regex","i).*iii.*pot","Status","Auto","Zone","-")
RANK_QUESTS["6_5"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["6_6"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["6_7"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["6_8"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["6_9"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["6_10"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["6_11"] := Map("Name","Use Flags","Regex","i)use.*flag","Status","Auto","Zone","-")
RANK_QUESTS["6_12"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["6_13"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["6_14"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["6_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["6_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["6_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["6_18"] := Map("Name","Catch Fish in the Fishing Minigame","Regex","i)fish(?!.*adv)","Status","Manual","Zone","27")
RANK_QUESTS["6_19"] := Map("Name","Find Chests in the Digsite","Regex","i)^(?!.*adv).*chest.*dig","Status","Manual","Zone","30")

; Tier 3
RANK_QUESTS["6_20"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["6_21"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["6_22"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["6_23"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["6_24"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["6_25"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["6_26"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["6_27"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["6_28"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["6_29"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["6_30"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["6_31"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["6_32"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["6_33"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")

; Tier 4
RANK_QUESTS["6_34"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["6_35"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["6_36"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["6_37"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["6_38"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["6_39"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["6_40"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")

; ========================================
; Rank 7
; ========================================

; Tier 1
RANK_QUESTS["7_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["7_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["7_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["7_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["7_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["7_6"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["7_7"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["7_8"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["7_9"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["7_10"] := Map("Name","Eat Fruits","Regex","i)fruit","Status","Auto","Zone","-")
RANK_QUESTS["7_11"] := Map("Name","Use Flags","Regex","i)use.*flag","Status","Auto","Zone","-")
RANK_QUESTS["7_12"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["7_13"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["7_14"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["7_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["7_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["7_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["7_18"] := Map("Name","Catch Fish in the Fishing Minigame","Regex","i)fish(?!.*adv)","Status","Manual","Zone","27")
RANK_QUESTS["7_19"] := Map("Name","Find Chests in the Digsite","Regex","i)^(?!.*adv).*chest.*dig","Status","Manual","Zone","30")

; Tier 3
RANK_QUESTS["7_20"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["7_21"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["7_22"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["7_23"] := Map("Name","Break Mini-Chests","Regex","i)mini.*chest(?!.*best)","Status","Manual","Zone","-")
RANK_QUESTS["7_24"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["7_25"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["7_26"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["7_27"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["7_28"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["7_29"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["7_30"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["7_31"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["7_32"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["7_33"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["7_34"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")

; Tier 4
RANK_QUESTS["7_35"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["7_36"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["7_37"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["7_38"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["7_39"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["7_40"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["7_41"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")

; ========================================
; Rank 8
; ========================================

; Tier 1
RANK_QUESTS["8_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["8_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["8_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["8_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["8_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["8_6"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["8_7"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["8_8"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["8_9"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["8_10"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["8_11"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["8_12"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["8_13"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["8_14"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["8_15"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["8_16"] := Map("Name","Catch Fish in the Fishing Minigame","Regex","i)fish(?!.*adv)","Status","Manual","Zone","27")
RANK_QUESTS["8_17"] := Map("Name","Find Chests in the Digsite","Regex","i)^(?!.*adv).*chest.*dig","Status","Manual","Zone","30")

; Tier 3
RANK_QUESTS["8_18"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["8_19"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["8_20"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["8_21"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["8_22"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["8_23"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["8_24"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["8_25"] := Map("Name","Use Tier 5 Potions","Regex","i).*\sv.*pot","Status","Auto","Zone","-")
RANK_QUESTS["8_26"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["8_27"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["8_28"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["8_29"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["8_30"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["8_31"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["8_32"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")

; Tier 4
RANK_QUESTS["8_33"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["8_34"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["8_35"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["8_36"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["8_37"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["8_38"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["8_39"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")

; ========================================
; Rank 9
; ========================================

; Tier 1
RANK_QUESTS["9_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["9_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["9_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["9_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["9_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["9_6"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["9_7"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["9_8"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["9_9"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["9_10"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["9_11"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["9_12"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["9_13"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["9_14"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["9_15"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["9_16"] := Map("Name","Catch Fish in the Fishing Minigame","Regex","i)fish(?!.*adv)","Status","Manual","Zone","27")
RANK_QUESTS["9_17"] := Map("Name","Find Chests in the Digsite","Regex","i)^(?!.*adv).*chest.*dig","Status","Manual","Zone","30")

; Tier 3
RANK_QUESTS["9_18"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["9_19"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["9_20"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["9_21"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["9_22"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["9_23"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["9_24"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["9_25"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["9_26"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["9_27"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["9_28"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["9_29"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["9_30"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")

; Tier 4
RANK_QUESTS["9_31"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["9_32"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["9_33"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["9_34"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["9_35"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["9_36"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["9_37"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")

; ========================================
; Rank 10
; ========================================

; Tier 1
RANK_QUESTS["10_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["10_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["10_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["10_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["10_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["10_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["10_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["10_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["10_9"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["10_10"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["10_11"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["10_12"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["10_13"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["10_14"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["10_15"] := Map("Name","Catch Fish in the Fishing Minigame","Regex","i)fish(?!.*adv)","Status","Manual","Zone","27")
RANK_QUESTS["10_16"] := Map("Name","Find Chests in the Digsite","Regex","i)^(?!.*adv).*chest.*dig","Status","Manual","Zone","30")

; Tier 3
RANK_QUESTS["10_17"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["10_18"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["10_19"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["10_20"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["10_21"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["10_22"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["10_23"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["10_24"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["10_25"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["10_26"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["10_27"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["10_28"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["10_29"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["10_30"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")

; Tier 4
RANK_QUESTS["10_31"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["10_32"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["10_33"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["10_34"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["10_35"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["10_36"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["10_37"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["10_38"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 11
; ========================================

; Tier 1
RANK_QUESTS["11_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["11_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["11_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["11_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["11_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["11_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["11_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["11_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["11_9"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["11_10"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["11_11"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["11_12"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["11_13"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["11_14"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["11_15"] := Map("Name","Catch Fish in the Fishing Minigame","Regex","i)fish(?!.*adv)","Status","Manual","Zone","27")
RANK_QUESTS["11_16"] := Map("Name","Find Chests in the Digsite","Regex","i)^(?!.*adv).*chest.*dig","Status","Manual","Zone","30")

; Tier 3
RANK_QUESTS["11_17"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["11_18"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["11_19"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["11_20"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["11_21"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["11_22"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["11_23"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["11_24"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["11_25"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["11_26"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["11_27"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["11_28"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["11_29"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["11_30"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")

; Tier 4
RANK_QUESTS["11_31"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["11_32"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["11_33"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["11_34"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["11_35"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["11_36"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["11_37"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["11_38"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 12
; ========================================

; Tier 1
RANK_QUESTS["12_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["12_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["12_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["12_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["12_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["12_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["12_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["12_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["12_9"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["12_10"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["12_11"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["12_12"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["12_13"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["12_14"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["12_15"] := Map("Name","Catch Fish in the Fishing Minigame","Regex","i)fish(?!.*adv)","Status","Manual","Zone","27")
RANK_QUESTS["12_16"] := Map("Name","Find Chests in the Digsite","Regex","i)^(?!.*adv).*chest.*dig","Status","Manual","Zone","30")

; Tier 3
RANK_QUESTS["12_17"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["12_18"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["12_19"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["12_20"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["12_21"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["12_22"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["12_23"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["12_24"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["12_25"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["12_26"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["12_27"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["12_28"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["12_29"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["12_30"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")

; Tier 4
RANK_QUESTS["12_31"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["12_32"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["12_33"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["12_34"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["12_35"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["12_36"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["12_37"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["12_38"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 13
; ========================================

; Tier 1
RANK_QUESTS["13_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["13_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["13_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["13_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["13_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["13_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["13_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["13_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["13_9"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["13_10"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["13_11"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["13_12"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["13_13"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["13_14"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["13_15"] := Map("Name","Catch Fish in the Fishing Minigame","Regex","i)fish(?!.*adv)","Status","Manual","Zone","27")
RANK_QUESTS["13_16"] := Map("Name","Find Chests in the Digsite","Regex","i)^(?!.*adv).*chest.*dig","Status","Manual","Zone","30")

; Tier 3
RANK_QUESTS["13_17"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["13_18"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["13_19"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["13_20"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["13_21"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["13_22"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["13_23"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["13_24"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["13_25"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["13_26"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["13_27"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["13_28"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["13_29"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["13_30"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")

; Tier 4
RANK_QUESTS["13_31"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["13_32"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["13_33"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["13_34"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["13_35"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["13_36"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["13_37"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["13_38"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 14
; ========================================

; Tier 1
RANK_QUESTS["14_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["14_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["14_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["14_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["14_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["14_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["14_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["14_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["14_9"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["14_10"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["14_11"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["14_12"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["14_13"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["14_14"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["14_15"] := Map("Name","Catch Fish in the Fishing Minigame","Regex","i)fish(?!.*adv)","Status","Manual","Zone","27")
RANK_QUESTS["14_16"] := Map("Name","Find Chests in the Digsite","Regex","i)^(?!.*adv).*chest.*dig","Status","Manual","Zone","30")

; Tier 3
RANK_QUESTS["14_17"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["14_18"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["14_19"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["14_20"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["14_21"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["14_22"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["14_23"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["14_24"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["14_25"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["14_26"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["14_27"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["14_28"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["14_29"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["14_30"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")

; Tier 4
RANK_QUESTS["14_31"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["14_32"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["14_33"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["14_34"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["14_35"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["14_36"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["14_37"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["14_38"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 15
; ========================================

; Tier 1
RANK_QUESTS["15_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["15_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["15_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["15_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["15_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["15_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["15_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["15_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["15_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["15_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["15_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["15_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["15_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["15_14"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["15_15"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["15_16"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["15_17"] := Map("Name","Catch Fish in the Fishing Minigame","Regex","i)fish(?!.*adv)","Status","Manual","Zone","27")
RANK_QUESTS["15_18"] := Map("Name","Find Chests in the Digsite","Regex","i)^(?!.*adv).*chest.*dig","Status","Manual","Zone","30")
RANK_QUESTS["15_19"] := Map("Name","Catch Fish in Advanced Fishing","Regex","i)(adv.*fish|fish.*adv)","Status","Manual","Zone","92")
RANK_QUESTS["15_20"] := Map("Name","Find Chests in the Advanced Digsite","Regex","i)(adv.*dig|chest.*adv)","Status","Manual","Zone","79")

; Tier 3
RANK_QUESTS["15_21"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["15_22"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["15_23"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["15_24"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["15_25"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["15_26"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["15_27"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["15_28"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["15_29"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["15_30"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["15_31"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["15_32"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["15_33"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["15_34"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["15_35"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["15_36"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")

; Tier 4
RANK_QUESTS["15_37"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["15_38"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["15_39"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["15_40"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["15_41"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["15_42"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["15_43"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["15_44"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 16
; ========================================

; Tier 1
RANK_QUESTS["16_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["16_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["16_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["16_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["16_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["16_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["16_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["16_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["16_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["16_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["16_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["16_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["16_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["16_14"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["16_15"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["16_16"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["16_17"] := Map("Name","Catch Fish in the Fishing Minigame","Regex","i)fish(?!.*adv)","Status","Manual","Zone","27")
RANK_QUESTS["16_18"] := Map("Name","Find Chests in the Digsite","Regex","i)^(?!.*adv).*chest.*dig","Status","Manual","Zone","30")
RANK_QUESTS["16_19"] := Map("Name","Catch Fish in Advanced Fishing","Regex","i)(adv.*fish|fish.*adv)","Status","Manual","Zone","92")
RANK_QUESTS["16_20"] := Map("Name","Find Chests in the Advanced Digsite","Regex","i)(adv.*dig|chest.*adv)","Status","Manual","Zone","79")

; Tier 3
RANK_QUESTS["16_21"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["16_22"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["16_23"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["16_24"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["16_25"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["16_26"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["16_27"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["16_28"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["16_29"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["16_30"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["16_31"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["16_32"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["16_33"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["16_34"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["16_35"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["16_36"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")

; Tier 4
RANK_QUESTS["16_37"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["16_38"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["16_39"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["16_40"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["16_41"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["16_42"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["16_43"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["16_44"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 17
; ========================================

; Tier 1
RANK_QUESTS["17_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["17_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["17_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["17_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["17_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["17_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["17_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["17_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["17_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["17_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["17_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["17_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["17_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["17_14"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["17_15"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["17_16"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["17_17"] := Map("Name","Catch Fish in the Fishing Minigame","Regex","i)fish(?!.*adv)","Status","Manual","Zone","27")
RANK_QUESTS["17_18"] := Map("Name","Find Chests in the Digsite","Regex","i)^(?!.*adv).*chest.*dig","Status","Manual","Zone","30")
RANK_QUESTS["17_19"] := Map("Name","Catch Fish in Advanced Fishing","Regex","i)(adv.*fish|fish.*adv)","Status","Manual","Zone","92")
RANK_QUESTS["17_20"] := Map("Name","Find Chests in the Advanced Digsite","Regex","i)(adv.*dig|chest.*adv)","Status","Manual","Zone","79")

; Tier 3
RANK_QUESTS["17_21"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["17_22"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["17_23"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["17_24"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["17_25"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["17_26"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["17_27"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["17_28"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["17_29"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["17_30"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["17_31"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["17_32"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["17_33"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["17_34"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["17_35"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["17_36"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")

; Tier 4
RANK_QUESTS["17_37"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["17_38"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["17_39"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["17_40"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["17_41"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["17_42"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["17_43"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["17_44"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 18
; ========================================

; Tier 1
RANK_QUESTS["18_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["18_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["18_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["18_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["18_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["18_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["18_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["18_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["18_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["18_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["18_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["18_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["18_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["18_14"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["18_15"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["18_16"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["18_17"] := Map("Name","Catch Fish in the Fishing Minigame","Regex","i)fish(?!.*adv)","Status","Manual","Zone","27")
RANK_QUESTS["18_18"] := Map("Name","Find Chests in the Digsite","Regex","i)^(?!.*adv).*chest.*dig","Status","Manual","Zone","30")
RANK_QUESTS["18_19"] := Map("Name","Catch Fish in Advanced Fishing","Regex","i)(adv.*fish|fish.*adv)","Status","Manual","Zone","92")
RANK_QUESTS["18_20"] := Map("Name","Find Chests in the Advanced Digsite","Regex","i)(adv.*dig|chest.*adv)","Status","Manual","Zone","79")

; Tier 3
RANK_QUESTS["18_21"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["18_22"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["18_23"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["18_24"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["18_25"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["18_26"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["18_27"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["18_28"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["18_29"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["18_30"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["18_31"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["18_32"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["18_33"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["18_34"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["18_35"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["18_36"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")

; Tier 4
RANK_QUESTS["18_37"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["18_38"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["18_39"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["18_40"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["18_41"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["18_42"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["18_43"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["18_44"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 19
; ========================================

; Tier 1
RANK_QUESTS["19_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["19_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["19_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["19_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["19_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["19_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["19_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["19_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["19_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["19_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["19_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["19_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["19_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["19_14"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["19_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["19_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["19_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["19_18"] := Map("Name","Catch Fish in the Fishing Minigame","Regex","i)fish(?!.*adv)","Status","Manual","Zone","27")
RANK_QUESTS["19_19"] := Map("Name","Find Chests in the Digsite","Regex","i)^(?!.*adv).*chest.*dig","Status","Manual","Zone","30")
RANK_QUESTS["19_20"] := Map("Name","Catch Fish in Advanced Fishing","Regex","i)(adv.*fish|fish.*adv)","Status","Manual","Zone","92")
RANK_QUESTS["19_21"] := Map("Name","Find Chests in the Advanced Digsite","Regex","i)(adv.*dig|chest.*adv)","Status","Manual","Zone","79")

; Tier 3
RANK_QUESTS["19_22"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["19_23"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["19_24"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["19_25"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["19_26"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["19_27"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["19_28"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["19_29"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["19_30"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["19_31"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["19_32"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["19_33"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["19_34"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["19_35"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["19_36"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["19_37"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")

; Tier 4
RANK_QUESTS["19_38"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["19_39"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["19_40"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["19_41"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["19_42"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["19_43"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["19_44"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["19_45"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 20
; ========================================

; Tier 1
RANK_QUESTS["20_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["20_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["20_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["20_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["20_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["20_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["20_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["20_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["20_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["20_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["20_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["20_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["20_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["20_14"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["20_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["20_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["20_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["20_18"] := Map("Name","Catch Fish in the Fishing Minigame","Regex","i)fish(?!.*adv)","Status","Manual","Zone","27")
RANK_QUESTS["20_19"] := Map("Name","Find Chests in the Digsite","Regex","i)^(?!.*adv).*chest.*dig","Status","Manual","Zone","30")
RANK_QUESTS["20_20"] := Map("Name","Catch Fish in Advanced Fishing","Regex","i)(adv.*fish|fish.*adv)","Status","Manual","Zone","92")
RANK_QUESTS["20_21"] := Map("Name","Find Chests in the Advanced Digsite","Regex","i)(adv.*dig|chest.*adv)","Status","Manual","Zone","79")

; Tier 3
RANK_QUESTS["20_22"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["20_23"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["20_24"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["20_25"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["20_26"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["20_27"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["20_28"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["20_29"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["20_30"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["20_31"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["20_32"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["20_33"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["20_34"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["20_35"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["20_36"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["20_37"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")

; Tier 4
RANK_QUESTS["20_38"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["20_39"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["20_40"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["20_41"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["20_42"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["20_43"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["20_44"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["20_45"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 21
; ========================================

; Tier 1
RANK_QUESTS["21_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["21_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["21_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["21_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["21_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["21_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["21_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["21_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["21_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["21_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["21_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["21_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["21_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["21_14"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["21_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["21_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["21_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["21_18"] := Map("Name","Catch Fish in the Fishing Minigame","Regex","i)fish(?!.*adv)","Status","Manual","Zone","27")
RANK_QUESTS["21_19"] := Map("Name","Find Chests in the Digsite","Regex","i)^(?!.*adv).*chest.*dig","Status","Manual","Zone","30")
RANK_QUESTS["21_20"] := Map("Name","Catch Fish in Advanced Fishing","Regex","i)(adv.*fish|fish.*adv)","Status","Manual","Zone","92")
RANK_QUESTS["21_21"] := Map("Name","Find Chests in the Advanced Digsite","Regex","i)(adv.*dig|chest.*adv)","Status","Manual","Zone","79")

; Tier 3
RANK_QUESTS["21_22"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["21_23"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["21_24"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["21_25"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["21_26"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["21_27"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["21_28"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["21_29"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["21_30"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["21_31"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["21_32"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["21_33"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["21_34"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["21_35"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["21_36"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["21_37"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")

; Tier 4
RANK_QUESTS["21_38"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["21_39"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["21_40"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["21_41"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["21_42"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["21_43"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["21_44"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["21_45"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 22
; ========================================

; Tier 1
RANK_QUESTS["22_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["22_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["22_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["22_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["22_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["22_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["22_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["22_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["22_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["22_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["22_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["22_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["22_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["22_14"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["22_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["22_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["22_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["22_18"] := Map("Name","Catch Fish in the Fishing Minigame","Regex","i)fish(?!.*adv)","Status","Manual","Zone","27")
RANK_QUESTS["22_19"] := Map("Name","Find Chests in the Digsite","Regex","i)^(?!.*adv).*chest.*dig","Status","Manual","Zone","30")
RANK_QUESTS["22_20"] := Map("Name","Catch Fish in Advanced Fishing","Regex","i)(adv.*fish|fish.*adv)","Status","Manual","Zone","92")
RANK_QUESTS["22_21"] := Map("Name","Find Chests in the Advanced Digsite","Regex","i)(adv.*dig|chest.*adv)","Status","Manual","Zone","79")

; Tier 3
RANK_QUESTS["22_22"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["22_23"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["22_24"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["22_25"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["22_26"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["22_27"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["22_28"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["22_29"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["22_30"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["22_31"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["22_32"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["22_33"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["22_34"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["22_35"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["22_36"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["22_37"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")

; Tier 4
RANK_QUESTS["22_38"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["22_39"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["22_40"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["22_41"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["22_42"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["22_43"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["22_44"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["22_45"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 23
; ========================================

; Tier 1
RANK_QUESTS["23_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["23_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["23_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["23_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["23_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["23_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["23_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["23_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["23_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["23_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["23_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["23_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["23_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["23_14"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["23_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["23_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["23_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["23_18"] := Map("Name","Catch Fish in the Fishing Minigame","Regex","i)fish(?!.*adv)","Status","Manual","Zone","27")
RANK_QUESTS["23_19"] := Map("Name","Find Chests in the Digsite","Regex","i)^(?!.*adv).*chest.*dig","Status","Manual","Zone","30")
RANK_QUESTS["23_20"] := Map("Name","Catch Fish in Advanced Fishing","Regex","i)(adv.*fish|fish.*adv)","Status","Manual","Zone","92")
RANK_QUESTS["23_21"] := Map("Name","Find Chests in the Advanced Digsite","Regex","i)(adv.*dig|chest.*adv)","Status","Manual","Zone","79")

; Tier 3
RANK_QUESTS["23_22"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["23_23"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["23_24"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["23_25"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["23_26"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["23_27"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["23_28"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["23_29"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["23_30"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["23_31"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["23_32"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["23_33"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["23_34"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["23_35"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["23_36"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["23_37"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")

; Tier 4
RANK_QUESTS["23_38"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["23_39"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["23_40"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["23_41"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["23_42"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["23_43"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["23_44"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["23_45"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 24
; ========================================

; Tier 1
RANK_QUESTS["24_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["24_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["24_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["24_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["24_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["24_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["24_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["24_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["24_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["24_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["24_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["24_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["24_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["24_14"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["24_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["24_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["24_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["24_18"] := Map("Name","Catch Fish in the Fishing Minigame","Regex","i)fish(?!.*adv)","Status","Manual","Zone","27")
RANK_QUESTS["24_19"] := Map("Name","Find Chests in the Digsite","Regex","i)^(?!.*adv).*chest.*dig","Status","Manual","Zone","30")
RANK_QUESTS["24_20"] := Map("Name","Catch Fish in Advanced Fishing","Regex","i)(adv.*fish|fish.*adv)","Status","Manual","Zone","92")
RANK_QUESTS["24_21"] := Map("Name","Find Chests in the Advanced Digsite","Regex","i)(adv.*dig|chest.*adv)","Status","Manual","Zone","79")

; Tier 3
RANK_QUESTS["24_22"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["24_23"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["24_24"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["24_25"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["24_26"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["24_27"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["24_28"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["24_29"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["24_30"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["24_31"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["24_32"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["24_33"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["24_34"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["24_35"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["24_36"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["24_37"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")

; Tier 4
RANK_QUESTS["24_38"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["24_39"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["24_40"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["24_41"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["24_42"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["24_43"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["24_44"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["24_45"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 25
; ========================================

; Tier 1
RANK_QUESTS["25_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["25_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["25_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["25_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["25_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["25_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["25_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["25_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["25_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["25_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["25_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["25_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["25_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["25_14"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["25_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["25_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["25_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["25_18"] := Map("Name","Catch Fish in the Fishing Minigame","Regex","i)fish(?!.*adv)","Status","Manual","Zone","27")
RANK_QUESTS["25_19"] := Map("Name","Find Chests in the Digsite","Regex","i)^(?!.*adv).*chest.*dig","Status","Manual","Zone","30")
RANK_QUESTS["25_20"] := Map("Name","Catch Fish in Advanced Fishing","Regex","i)(adv.*fish|fish.*adv)","Status","Manual","Zone","92")
RANK_QUESTS["25_21"] := Map("Name","Find Chests in the Advanced Digsite","Regex","i)(adv.*dig|chest.*adv)","Status","Manual","Zone","79")

; Tier 3
RANK_QUESTS["25_22"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["25_23"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["25_24"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["25_25"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["25_26"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["25_27"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["25_28"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["25_29"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["25_30"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["25_31"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["25_32"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["25_33"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["25_34"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["25_35"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["25_36"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["25_37"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")

; Tier 4
RANK_QUESTS["25_38"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["25_39"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["25_40"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["25_41"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["25_42"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["25_43"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["25_44"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["25_45"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 26
; ========================================

; Tier 1
RANK_QUESTS["26_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["26_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["26_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["26_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["26_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["26_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["26_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["26_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["26_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["26_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["26_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["26_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["26_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["26_14"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["26_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["26_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["26_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["26_18"] := Map("Name","Catch Fish in the Fishing Minigame","Regex","i)fish(?!.*adv)","Status","Manual","Zone","27")
RANK_QUESTS["26_19"] := Map("Name","Find Chests in the Digsite","Regex","i)^(?!.*adv).*chest.*dig","Status","Manual","Zone","30")
RANK_QUESTS["26_20"] := Map("Name","Catch Fish in Advanced Fishing","Regex","i)(adv.*fish|fish.*adv)","Status","Manual","Zone","92")
RANK_QUESTS["26_21"] := Map("Name","Find Chests in the Advanced Digsite","Regex","i)(adv.*dig|chest.*adv)","Status","Manual","Zone","79")

; Tier 3
RANK_QUESTS["26_22"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["26_23"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["26_24"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["26_25"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["26_26"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["26_27"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["26_28"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["26_29"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["26_30"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["26_31"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["26_32"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["26_33"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["26_34"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["26_35"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["26_36"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")
RANK_QUESTS["26_37"] := Map("Name","Unlock Zones","Regex","i)unlock","Status","Manual","Zone","-")

; Tier 4
RANK_QUESTS["26_38"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["26_39"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["26_40"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["26_41"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["26_42"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["26_43"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["26_44"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["26_45"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 27
; ========================================

; Tier 1
RANK_QUESTS["27_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["27_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["27_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["27_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["27_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["27_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["27_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["27_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["27_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["27_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["27_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["27_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["27_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["27_14"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["27_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["27_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["27_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 3
RANK_QUESTS["27_18"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["27_19"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["27_20"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["27_21"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["27_22"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["27_23"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["27_24"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["27_25"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["27_26"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["27_27"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["27_28"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["27_29"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["27_30"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["27_31"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["27_32"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 4
RANK_QUESTS["27_33"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["27_34"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["27_35"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["27_36"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["27_37"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["27_38"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["27_39"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["27_40"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 28
; ========================================

; Tier 1
RANK_QUESTS["28_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["28_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["28_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["28_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["28_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["28_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["28_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["28_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["28_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["28_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["28_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["28_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["28_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["28_14"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["28_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["28_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["28_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 3
RANK_QUESTS["28_18"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["28_19"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["28_20"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["28_21"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["28_22"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["28_23"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["28_24"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["28_25"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["28_26"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["28_27"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["28_28"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["28_29"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["28_30"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["28_31"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["28_32"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 4
RANK_QUESTS["28_33"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["28_34"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["28_35"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["28_36"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["28_37"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["28_38"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["28_39"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["28_40"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 29
; ========================================

; Tier 1
RANK_QUESTS["29_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["29_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["29_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["29_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["29_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["29_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["29_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["29_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["29_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["29_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["29_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["29_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["29_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["29_14"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["29_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["29_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["29_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 3
RANK_QUESTS["29_18"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["29_19"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["29_20"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["29_21"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["29_22"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["29_23"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["29_24"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["29_25"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["29_26"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["29_27"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["29_28"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["29_29"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["29_30"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["29_31"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["29_32"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 4
RANK_QUESTS["29_33"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["29_34"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["29_35"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["29_36"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["29_37"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["29_38"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["29_39"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["29_40"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 30
; ========================================

; Tier 1
RANK_QUESTS["30_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["30_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["30_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["30_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["30_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["30_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["30_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["30_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["30_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["30_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["30_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["30_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["30_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["30_14"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["30_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["30_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["30_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 3
RANK_QUESTS["30_18"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["30_19"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["30_20"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["30_21"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["30_22"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["30_23"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["30_24"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["30_25"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["30_26"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["30_27"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["30_28"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["30_29"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["30_30"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["30_31"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["30_32"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 4
RANK_QUESTS["30_33"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["30_34"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["30_35"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["30_36"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["30_37"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["30_38"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["30_39"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["30_40"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 31
; ========================================

; Tier 1
RANK_QUESTS["31_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["31_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["31_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["31_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["31_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["31_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["31_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["31_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["31_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["31_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["31_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["31_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["31_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["31_14"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["31_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["31_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["31_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 3
RANK_QUESTS["31_18"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["31_19"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["31_20"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["31_21"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["31_22"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["31_23"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["31_24"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["31_25"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["31_26"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["31_27"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["31_28"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["31_29"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["31_30"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["31_31"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["31_32"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 4
RANK_QUESTS["31_33"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["31_34"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["31_35"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["31_36"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["31_37"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["31_38"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["31_39"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["31_40"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 32
; ========================================

; Tier 1
RANK_QUESTS["32_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["32_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["32_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["32_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["32_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["32_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["32_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["32_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["32_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["32_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["32_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["32_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["32_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["32_14"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["32_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["32_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["32_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 3
RANK_QUESTS["32_18"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["32_19"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["32_20"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["32_21"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["32_22"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["32_23"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["32_24"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["32_25"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["32_26"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["32_27"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["32_28"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["32_29"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["32_30"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["32_31"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["32_32"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 4
RANK_QUESTS["32_33"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["32_34"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["32_35"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["32_36"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["32_37"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["32_38"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["32_39"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["32_40"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 33
; ========================================

; Tier 1
RANK_QUESTS["33_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["33_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["33_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["33_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["33_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["33_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["33_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["33_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["33_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["33_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["33_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["33_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["33_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["33_14"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["33_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["33_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["33_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 3
RANK_QUESTS["33_18"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["33_19"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["33_20"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["33_21"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["33_22"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["33_23"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["33_24"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["33_25"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["33_26"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["33_27"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["33_28"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["33_29"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["33_30"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["33_31"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["33_32"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 4
RANK_QUESTS["33_33"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["33_34"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["33_35"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["33_36"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["33_37"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["33_38"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["33_39"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["33_40"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 34
; ========================================

; Tier 1
RANK_QUESTS["34_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["34_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["34_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["34_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["34_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["34_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["34_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["34_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["34_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["34_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["34_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["34_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["34_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["34_14"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["34_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["34_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["34_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 3
RANK_QUESTS["34_18"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["34_19"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["34_20"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["34_21"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["34_22"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["34_23"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["34_24"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["34_25"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["34_26"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["34_27"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["34_28"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["34_29"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["34_30"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["34_31"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["34_32"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 4
RANK_QUESTS["34_33"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["34_34"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["34_35"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["34_36"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["34_37"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["34_38"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["34_39"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["34_40"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 35
; ========================================

; Tier 1
RANK_QUESTS["35_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["35_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["35_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["35_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["35_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["35_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["35_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["35_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["35_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["35_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["35_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["35_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["35_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["35_14"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["35_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["35_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["35_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 3
RANK_QUESTS["35_18"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["35_19"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["35_20"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["35_21"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["35_22"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["35_23"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["35_24"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["35_25"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["35_26"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["35_27"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["35_28"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["35_29"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["35_30"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["35_31"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["35_32"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 4
RANK_QUESTS["35_33"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["35_34"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["35_35"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["35_36"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["35_37"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["35_38"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["35_39"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["35_40"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 36
; ========================================

; Tier 1
RANK_QUESTS["36_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["36_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["36_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["36_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["36_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["36_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["36_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["36_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["36_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["36_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["36_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["36_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["36_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["36_14"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["36_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["36_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["36_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 3
RANK_QUESTS["36_18"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["36_19"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["36_20"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["36_21"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["36_22"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["36_23"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["36_24"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["36_25"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["36_26"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["36_27"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["36_28"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["36_29"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["36_30"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["36_31"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["36_32"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 4
RANK_QUESTS["36_33"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["36_34"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["36_35"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["36_36"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["36_37"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["36_38"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["36_39"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["36_40"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 37
; ========================================

; Tier 1
RANK_QUESTS["37_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["37_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["37_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["37_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["37_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["37_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["37_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["37_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["37_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["37_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["37_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["37_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["37_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["37_14"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["37_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["37_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["37_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 3
RANK_QUESTS["37_18"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["37_19"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["37_20"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["37_21"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["37_22"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["37_23"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["37_24"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["37_25"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["37_26"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["37_27"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["37_28"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["37_29"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["37_30"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["37_31"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["37_32"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 4
RANK_QUESTS["37_33"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["37_34"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["37_35"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["37_36"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["37_37"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["37_38"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["37_39"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["37_40"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 38
; ========================================

; Tier 1
RANK_QUESTS["38_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["38_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["38_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["38_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["38_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["38_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["38_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["38_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["38_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["38_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["38_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["38_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["38_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["38_14"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["38_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["38_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["38_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 3
RANK_QUESTS["38_18"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["38_19"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["38_20"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["38_21"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["38_22"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["38_23"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["38_24"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["38_25"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["38_26"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["38_27"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["38_28"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["38_29"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["38_30"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["38_31"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["38_32"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 4
RANK_QUESTS["38_33"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["38_34"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["38_35"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["38_36"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["38_37"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["38_38"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["38_39"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["38_40"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 39
; ========================================

; Tier 1
RANK_QUESTS["39_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["39_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["39_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["39_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["39_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["39_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["39_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["39_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["39_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["39_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["39_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["39_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["39_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["39_14"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["39_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["39_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["39_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 3
RANK_QUESTS["39_18"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["39_19"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["39_20"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["39_21"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["39_22"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["39_23"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["39_24"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["39_25"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["39_26"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["39_27"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["39_28"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["39_29"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["39_30"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["39_31"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["39_32"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 4
RANK_QUESTS["39_33"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["39_34"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["39_35"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["39_36"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["39_37"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["39_38"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["39_39"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["39_40"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")

; ========================================
; Rank 40
; ========================================

; Tier 1
RANK_QUESTS["40_1"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["40_2"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["40_3"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["40_4"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")

; Tier 2
RANK_QUESTS["40_5"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["40_6"] := Map("Name","Collect Potions","Regex","i)col.*pot","Status","Auto","Zone","Best")
RANK_QUESTS["40_7"] := Map("Name","Collect Enchants","Regex","i)col.*ench","Status","Auto","Zone","Best")
RANK_QUESTS["40_8"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["40_9"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["40_10"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["40_11"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["40_12"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["40_13"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["40_14"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["40_15"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["40_16"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["40_17"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 3
RANK_QUESTS["40_18"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["40_19"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["40_20"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["40_21"] := Map("Name","Upgrade Potions","Regex","i)upg.*pot","Status","Manual","Zone","Best")
RANK_QUESTS["40_22"] := Map("Name","Upgrade Enchants","Regex","i)upg.*ench","Status","Manual","Zone","Best")
RANK_QUESTS["40_23"] := Map("Name","Use Tier 4 Potions","Regex","i).*(iv|lv).*pot","Status","Auto","Zone","-")
RANK_QUESTS["40_24"] := Map("Name","Break Lucky Blocks in Best Area","Regex","i)lucky.*block.*best","Status","Auto","Zone","Best")
RANK_QUESTS["40_25"] := Map("Name","Break Pinatas in Best Area","Regex","i)pi.*ata.*best","Status","Auto","Zone","Best")
RANK_QUESTS["40_26"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["40_27"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["40_28"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["40_29"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")
RANK_QUESTS["40_30"] := Map("Name","Hatch Best Egg","Regex","i)your.*bes","Status","Auto","Zone","Best")
RANK_QUESTS["40_31"] := Map("Name","Make Golden Pets from Best Egg","Regex","i)golden.*best","Status","Auto","Zone","Best")
RANK_QUESTS["40_32"] := Map("Name","Make Rainbow Pets from Best Egg","Regex","i)rainbow.*best","Status","Auto","Zone","Best")

; Tier 4
RANK_QUESTS["40_33"] := Map("Name","Break Breakables in Best Area","Regex","i)break.*break.*area","Status","Auto","Zone","Best")
RANK_QUESTS["40_34"] := Map("Name","Break Diamond Breakables","Regex","i)break.*diamond(?!.*best)","Status","Auto","Zone","VIP")
RANK_QUESTS["40_35"] := Map("Name","Earn Diamonds","Regex","i)diamonds","Status","Auto","Zone","-")
RANK_QUESTS["40_36"] := Map("Name","Hatch Legendary Pets","Regex","i)legendary.*pet","Status","Auto","Zone","Best")
RANK_QUESTS["40_37"] := Map("Name","Break Comets in Best Area","Regex","i)(comet|cornet).*best","Status","Auto","Zone","Best")
RANK_QUESTS["40_38"] := Map("Name","Break Coin Jars in Best Area","Regex","i)coin.*jar.*best","Status","Auto","Zone","Best")
RANK_QUESTS["40_39"] := Map("Name","Break Mini-Chests in Best Area","Regex","i)^(?!.*sup).*mini.*best","Status","Auto","Zone","Best")
RANK_QUESTS["40_40"] := Map("Name","Break Superior Mini-Chests in Best Area","Regex","i)sup","Status","Auto","Zone","Best")


; ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰
; QUEST PROPERTY OVERRIDES
; ----------------------------------------------------------------------------------------
; The quest property overrides listed below are utilized by the macro and should not be
; altered by the user.
; ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰

; Update the zone if the player does not have VIP.
if (getSetting("HasGamepassVip") == "false") {
    for questId, questData in RANK_QUESTS {
        if (questData["Name"] == "Break Diamond Breakables")
            questData["Zone"] := "-"
    }
}

; Update the zone if the player has Super Drops.
if (getSetting("HasGamepassSuperDrops") == "true") {
    for questId, questData in RANK_QUESTS {
        if (questData["Name"] == "Collect Potions" || questData["Name"] == "Collect Enchants")
            questData["Zone"] := "-"
    }
}
