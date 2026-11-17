import { UIAbility } from '@kit.AbilityKit'
import { window } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import { birthStore } from '../store/BirthStore'

export default class EntryAbility extends UIAbility {
  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    try {
      await birthStore.init(this.context)
    } catch (error) {
      console.error('[Bazi] 初始化本地存储失败：' + JSON.stringify(error))
    }
    windowStage.loadContent('pages/Index', (error: BusinessError) => {
      if (error.code !== 0) {
        console.error('[Bazi] 加载首页失败：' + error.message)
      }
    })
  }
}
