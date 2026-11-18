/**
 * 生辰本地存档：preferences 持久化，用户下次打开直接出结果。
 */
import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { BirthInput } from '../model/Bazi'

export class BirthStore {
  private prefs: preferences.Preferences | undefined = undefined
  /** 最近一次【已查询】的生辰：表单回填与结果页都读它（不消费，可反复读） */
  private queried: BirthInput | null = null
  /** 表单当前草稿 */
  private draft: BirthInput | null = null

  setQueried(o: BirthInput): void {
    this.queried = o
  }

  getQueried(): BirthInput | null {
    return this.queried
  }

  setDraft(o: BirthInput): void {
    this.draft = o
  }

  getDraft(): BirthInput | null {
    return this.draft
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
