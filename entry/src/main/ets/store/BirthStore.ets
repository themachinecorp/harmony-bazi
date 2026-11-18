/**
 * 生辰本地存档：preferences 持久化，用户下次打开直接出结果。
 */
import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { BirthInput } from '../model/Bazi'

export class BirthStore {
  private prefs: preferences.Preferences | undefined = undefined
  /** 内存态：录入页 → 结果页直接传递，避免依赖落盘时序造成读到旧值 */
  private pending: BirthInput | null = null

  setPending(o: BirthInput): void {
    this.pending = o
  }

  takePending(): BirthInput | null {
    const o: BirthInput | null = this.pending
    this.pending = null
    return o
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    try {
      this.prefs = await preferences.getPreferences(context, { name: 'bazi_store' })
    } catch (e) {
      console.error('[Bazi] 打开本地存储失败：' + JSON.stringify(e))
    }
  }

  async save(o: BirthInput): Promise<void> {
    if (this.prefs === undefined) {
      return
    }
    try {
      await this.prefs.put('birth', JSON.stringify(o))
      await this.prefs.flush()
    } catch (e) {
      console.error('[Bazi] 保存失败：' + JSON.stringify(e))
    }
  }

  async load(): Promise<BirthInput | null> {
    if (this.prefs === undefined) {
      return null
    }
    try {
      const v = await this.prefs.get('birth', '') as string
      if (!v) {
        return null
      }
      const o = JSON.parse(v) as BirthInput
      return o
    } catch (e) {
      console.error('[Bazi] 读取失败：' + JSON.stringify(e))
      return null
    }
  }
}

export const birthStore: BirthStore = new BirthStore()
