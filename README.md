# 计算机安全考试
  计算机安全知识点梳理
  在 ESFJ-MoZhu 的资料的基础上整理的内容。
  
  ## 已知的考试形式
  类似机器学习(CYX)的形式，重点复习实验内容。
***
  ## 1. 对抗样本
  * 当模型并不完美时才有可能会出现对抗样本。
  ### 1.1. 出现攻击与消失攻击
  出现攻击，也叫 adversarial appearance attack，指攻击者通过添加对抗性扰动或对抗性图案，让一个本来不在目标类别的样本，被模型错误识别为目标类别。
  * 比如：在街道上放一个特制对抗性贴纸，让自动驾驶识别为「停车标志」。
  消失攻击，也叫 adversarial disappearance attack，指攻击者对本来应该被模型检测到或识别出的目标，添加对抗性扰动，使得目标从模型视角“消失”。
  * 比如：穿一件特制的对抗性 T 恤，让行人检测模型检测不到人。

  距离函数

  定向攻击与非定向攻击

  训练与攻击其实是对偶关系，训练是想让学习一个分类器，使得输入的预测结果与真实标签尽量接近，而攻击是找到一个扰动使损失函数最大化，从而让模型预测错误.

  梯度下降的思路，找到一个小扰动 𝛿让损失函数最大化，结合泰勒展开等等。（扰动将沿着梯度的方向向损失函数极大值移动）

  线性模型的对抗样本，在高维空间中，每一维的扰动积累起来，可能导致整体输出的大幅度变化，也会收到攻击。

  DNN大多是分段线性的，比如卷积层；分段线性函数 ReLU , Sigmoid 函数不是线性的，但在一定范围内近似为线性。神经网络的线性特性导致了对抗样本的脆弱性。

  对抗样本的对抗扰动不是随机的，是需要计算梯度最大处刻意安排。

  不同对抗攻击方法原理类似，差异会因为`损失函数`,`约束条件`,`优化算法`而不同。

  投影梯度下降法，Carlini-Wagner攻击，单像素攻击，Universal Adversarial Perturbation通用对抗扰动，Zeroth Order Optimization(ZOO)零阶优化方法。
  * 其中，FGSM是F<sub>∞</sub>距离函数，FGM是F<sub>1</sub>距离函数。
  * PGD是在FGM的基础上进行多次迭代，稳步推进。
  * 单像素攻击利用差分进化算法。
  * 通用对抗扰动针对一个数据集使用一个通用并且小的扰动向量。
  * ZOO零阶优化方法使用对称分量对梯度进行估计

  Kerckhoffs原则:即便攻击者了解系统的设计和算法，只要密钥安全，系统就应该安全。
  ### 1.2. 防御策略:
  * 数据预处理，输入模型前移除对抗噪声。
  * 模型加固，修改模型架构，训练流程以提升鲁棒性。(对抗训练，正则化，网络结构改进)
  * 对抗样本检测，(输入特征分析，置信度阈值，特定网络检测器)
  * 防御性蒸馏
  * 对抗训练：在训练过程中引入对抗扰动，将生成的对抗样本也加入到数据集中，使得模型在有攻击的情况下也能正确分类。
    * 限制:损失函数不是连续可微的，因为神经网络中的 ReLU 和 max-pooling 操作会引入非光滑性,我们只能近似找到最优扰动，而非严格意义上的全局最优.慢且不具可扩展性, 训练速度慢 2~20 倍,如果扰动弱，模型可能并未真正学到鲁棒性。
***
  ## 2. 模型后门与数据投毒攻击
  ### 2.1. 数据投毒是后门攻击的主要手段
  Outsourcing Attack（外包攻击）：将训练过程交给第三方时第三方可以在训练过程中添加后门。（中间人搞事）
  
  Pretrained Attack（预训练模型攻击）：攻击者可以下载一个流行的预训练模型，在其中植入后门再重新发布给公众使用。开源社区中流行的预训练模型极易成为攻击的载体。
    *思路:诱导模型增强局部链接：
      1. 寻找最大化激活某个神经元的 pattern 
      2. 逆向生成最大化某类别的训练数据 
      3. 逆向数据 + pattern => 重新训练模型
  
  Data Collection Attack （数据收集攻击）：数据收集容易受到不可信来源的影响。受害者从公共来源收集数据，却没有意识到其中一些数据已经被投毒。
  
  Targeted Clean-Label Attack 有针对性的干净标签攻击：中毒图像的标签与视觉感官是一致的。攻击者不能直接篡改标签，只能投毒图像（感觉像对抗样本）
    * Watermarking(水印攻击),Multiple Instance Attack(多实例攻击)

  Collaborative Learning Attack(联邦学习攻击)：这个场景是关于以分布式学习技术为代表的协作学习，例如联邦学习和拆分学习。协作学习或分布式学习旨在保护clients的数据隐私不泄露，在学习阶段，server无法访问clients的训练数据，这使得协作学习很容易受到各种攻击，其中包括后门攻击。当少数clients被攻击者控制时，可以轻松地将后门植入联合学习的模型中，攻击者可以进行局部数据投毒和模型投毒。

  Post-Deployment Attack（部署后攻击）：此攻击面通常发生在模型部署后的推理阶段（预测阶段）。主要通过故障注入（例如激光、电压和row hammer）来篡改模型权重。比如当用户启动ML模型并将ML权重加载到内存中时，通过触发row hammer错误来间接翻转权重的一些位，从而导致推理准确度下降。

  Poisoning Attack（代码投毒攻击）：代码中嵌入了后门逻辑，旨在污染训练后的模型。
  * 代码投毒攻击需要攻击者掌控部署模型的系统。其优势是可以绕过绝大多数的防御对策。  
  
  后门攻击也可以被善意使用，例如模型开发者可以故意对自己的模型使用水印攻击用于知识产权保护。

  ### 2.2. 防御手段
  1. 后门检测：检测后门样本或后门模型。
  2. 后门移除：从后门模型中移除后门触发器。
  * ABS（Activation-based Backdoor Scanning, 基于激活的后门检测）方法。后门神经元在被特定触发器激活时，会导致目标输出类别异常激活。这种现象体现在某些神经元的激活值达到特殊水平时，网络输出几乎只依赖这些神经元，而对其他神经元不敏感。正常模型不会出现“单个神经元控制输出”的异常模式。
***
  ## 3. 模型提取攻击
  ### 3.1. 攻击手段
  * 方程求解方法与通过学习模拟的方法
  攻击者（adversarial client）通过尽可能少的查询，学习到目标模型 𝑓的“近似拷贝” 𝑓′,使得 𝑓′(𝑥) 和f(x) 在 99.9% 以上输入上输出一致。
  * 对逻辑回归模型的提取攻击，变换方程根据输入输出推测w和b
  * Generic Equation-Solving Attack（通用方程求解攻击）攻击者准备一批输入 X,这些输入送入远程的机器学习服务,服务返回置信度,用优化算法（如梯度下降）反复调整 W，使损失最小。总结来说构造输入 → 查询模型 → 收集输出 → 拟合自己的神经网络参数
  * 模型反演攻击（Model Inversion Attack）：利用模型提取的结果，推出训练数据。步骤是先提取模型功能，再逆向敏感数据。
  * Extracting a Decision Tree：输入𝑥和x′仅有一个特征不同。如果x和x′最终落在不同的叶节点，说明树在这个特征上进行了分裂。通过构造和查询不同输入，可以一步步推断出决策树在各特征上的分裂点，最终还原整棵树
  * Generic Model Retraining Attack（通用模型重训练攻击）：远不如方程求解法高效。主动学习可以大幅提升模型“扒取”效率，但在深度非线性模型下仍比直接方程求解低效许多
  ### 3.2. 防御
  * API最小化是一种防御策略,只返回类别标签，不返回置信度分数。但是，如果攻击者能用成员资格查询，依然能学习模型（如低效攻击）
  * 限制预测信息，例如仅返回类别标签，而不返回或修改/隐藏/四舍五入置信度值
  * 使用多个模型的组合来增加攻击难度，提高鲁棒性
  * 通过差分隐私技术保护模型参数，防止攻击者通过查询推测模型内部信息。
  ### 3.3. 学习模拟的思路
  基于替代模型的攻击，思路是在查询目标模型的过程中训练一个替代模型用于模拟其行为。
  * Knockoff nets：采样大量查询样本后训练替代模型。强化学习，学习如何高效选择样本（拿别人的输出自己学）。
  * 思路为：半监督学习
  * 对于替代模型的训练 ≈ 模型蒸馏
  * 借助密码分析方法进行分析：ReLU的二阶导为0 & 有限差分。功能等同于模型提取。（Extraction）。
  * Data-Free Model Extraction 数据无依赖模型提取：是指在没有真实原始数据（训练数据或查询数据）的情况下，通过只与目标模型交互，或者通过生成合成数据，对模型进行提取、克隆或蒸馏。
  ### 3.4. 其他的模型提取攻击方式
  物理窃取（侧信道攻击）；大模型窃取

***
  ## 4. 数据提取攻击 
  模型反演攻击（Model Inversion Attack），利用模型提取的结果，推出训练数据。
  ### 4.1. 下述说法是等价的：
  * Data Extraction Attack（数据提取攻击）
  * Data Stealing Attack（数据窃取攻击）
  * Training Data Extraction Attack（训练数据提取攻击）
  * Model Memorization Attack（模型记忆攻击）
  * Model Inversion Attack（模型反演攻击）
  ### 4.2. 一些定义
  * 模型容量 (Model Capacity)：DNN的参数数量通常远大于训练样本数，使其具有记住训练数据的能力。
      * 示例：ResNet-50有约2500万个参数，而CIFAR-10数据集仅包含6万张图像。

  * 优化目标 (Optimization Objective)：DNN的训练目标是最小化损失函数（如交叉熵），可能导致对噪声或异常样本的过拟合。
      * 示例：若某张图像被错误标注，DNN可能通过记住该样本来降低损失。

  * 数据分布 (Data Distribution)：训练数据中的噪声、重复样本或敏感信息可能被DNN记住。
      * 示例：医疗数据中的罕见病例可能被DNN记住，导致隐私泄露。

  ### 4.2. 模型反演（数据提取）的实现方法
  * 梯度下降
  ```
  函数 MI-FACE(label, α, β, γ, λ):
      c(x) 定义为 1 - f_label(x) + AUXTERM(x)  # 损失函数定义
      x₀ ← 0                                   # 初始化输入

      对 i = 1 到 α:
          xᵢ ← PROCESS(xᵢ₋₁ - λ ⋅ ∇c(xᵢ₋₁))    # 通过梯度下降更新输入

          如果 c(xᵢ) ≥ max(c(xᵢ₋₁), ..., c(xᵢ₋β)) :
              break                             # 若损失大于过去β次中的最大值，则终止

          如果 c(xᵢ) ≤ γ :
              break                             # 如果损失小于阈值γ，则终止

      返回 [argminₓ c(xᵢ), minₓ c(xᵢ)]         # 返回损失最小的输入和对应的损失值
  ```
  ### 4.3. 防御
  * 四舍五入处理，通过减少置信度值的精度，来削弱攻击者从模型输出中获取过多信息的能力
  * Exposure-based Testing Method ，通过加入随机的训练数据(金丝雀canary)，看看模型查询模型，看其是否能够回忆出。若能回忆出，说明模型具有较强的记忆能力，存在泄漏训练数据的风险

  ### 4.4. 总结
  1. 无意记忆的发生并不依赖于过拟合的产生，甚至都不是过度训练导致的
  2. 不常见的随机训练数据会在模型达到最大效用之前就被记住了
  3. weight decay（权重衰减）, dropout, and quantization（量化） 三种 regularization 方法（正则化技术）均不能解决记忆问题
  4. 使用 Differential Privacy 可以防止模型记忆化，但模型能力也被削弱
***
  ## 5. 隐私推理攻击
  分为成员推理攻击（Membership Inference Attack, MIA）和属性推理攻击（Attribute Inference Attack）和其他推理攻击。
  ### 5.1. 成员推理攻击
  Membership Inference Attack (MIA)判断一个用户是否参与了模型的训练数据。最常见的思路从数据集 𝐷中抽样出多个子集,在每个子集上训练一个模型,选择其中一个模型作为目标模型, 其余的模型作为影子模型。

  MIA局限性：
  * 需要构造影子模型（shadow models），增加攻击复杂度和成本；
  * 这需要要求攻击者能够获取某些数据或具有先验知识。
  * 模型必须发生过拟合，攻击才能有效；模型未发生过拟合时，成员和非成员样本表现趋同，难以区分。
  * 当前大多数方法仅适用于分类模型，并且在大模型上攻击效果下降，主要在小模型（如简单CNN）上实验验证。
  
  基于指标的异常检测:预测正确性(预测正确的就是成员),预测损失(低于训练样本平均损失的是成员),预测置信度(有概率接近1的是成员),预测熵(低概率熵的是成员),修正预测熵(不同类别区别考虑)。指标从前往后越来越精确。
  ### 5.2. 其他隐私推断攻击
  Property Inference属性推断.举例：即使性别不是数据集的特征之一，也可以从训练模型的数据集中推断出女性和男性患者的比例
  *  Attribute Inference特征值推断
  ### 5.1. 防范措施
  对数据隐私的保护
  * 推理阶段的数据隐私保护算法：在模型的推理阶段施加防御手段；
  * 训练阶段的数据隐私保护算法：在模型的训练阶段施加防御手段；
  
  对于推理阶段的隐私保护算法：用 AE 的思想抵抗成员推理模型的分类结果。对模型的原始输出 𝑠（即每个类别的预测概率）添加一个小的扰动 r，得到新的输出 𝑠+𝑟。希望添加的扰动𝑟要尽量小，这样不会影响模型的原有预测性能。扰动后的输出 𝑠+𝑟要让攻击者的推理模型 𝑔输出“成员概率”为 0.5(最好的情况)，也就是“非常不确定”，无法判断是不是成员。

  对于训练阶段的隐私保护算法：假设模型训练时，每个训练数据执行 SGD 时计算的梯度决定了模型保存训练数据的信息量。而训练数据在模型中信息是通过训练阶段的计算出的每个样本的梯度来体现的，如果有一个数据在训练过程中贡献的梯度比其他数据都大，那这个模型在梯度下降时，会更多地沿该数据贡献的梯度下降，也就是记住了更多关于这个数据的信息。那么，这个数据就会比其他数据更容易泄露隐私。因此，对每一个训练数据贡献的梯度加上（差分）噪声，使得模型不会学习到具体某一个数据提供的梯度。

  对模型版权的保护
  * 数字水印（Digital Watermark）

  白盒水印:嵌入水印，提取水印，验证所有权。添加惩罚项将水印嵌入模型，提取实用对应的提取矩阵提取。

  黑盒水印:水印的验证不需要模型参数,是一种后门攻击。嵌入方式:训练时加入特定“水印”样本到训练数据中。验证方式:在不接触模型内部参数的情况下，只用这些特殊水印样本作为输入，观察模型是否给出特定输出。如果模型能识别这些水印数据，则说明该模型嵌入了水印
***
  ## 6. 差分隐私
  对于只相差一条记录（行）的两个数据集（D 和 D'），无论用哪个数据集来计算，最终输出的结果（Outcome）都应该“非常相似”，这样就能保证，单个人的数据是否在数据集里，不会对分析结果产生显著影响，从而保护了个人隐私。
  * 𝜀-差分隐私
  * 随机响应 随机响应引入了“故意的随机噪声”，它的目的是牺牲一定的准确性，来换取更强的隐私保护。单个个体的回答：不准确，因为有概率是故意“反着回答”的。整体统计结果：准确！虽然每个人的回答可能掺杂了随机性，但通过大量样本统计，可以用数学方法校正偏差，还原总体的真实分布
  ......
***
  ## 7. 能量延迟
  模型初始化时的数据肯定不会给出正确结果，训练的过程就是“搅拌”网络参数（或者说权重），最终找到一组参数使得模型的输出结果看起来正确。
  * 影响每次推理所消耗能量的主要因素：输入数据在计算过程中所需的算术运算次数，访问内存的次数
  * 海绵样本:攻击者精心设计某些输入，这些输入会让模型在推理时陷入大量计算和内存访问，大幅度提高耗时和能耗
***
  ## 8. 可解释性
  ### 8.1. 可解释性的重要性
  * Fairness（公平性）： 确保预测无偏见
  * Privacy（隐私性）： 确保数据中的敏感信息得到保护
  * Safety and Robustness（安全和鲁棒性）：确保输入的微小变化不会导致预测的巨大变化
  * Causality（因果性）： 检查是否只选取因果关系
  * Trust（可信赖）： 与黑盒子相比，人类更容易信任一个能够解释其决定的系统。

  Fairness（公平性）Privacy（隐私性）Safety and Robustness（安全和鲁棒性）Causality（因果性）Trust（可信赖）
  并没有一个很严格的定义
  * 机器学习的步骤：
    1. 准备输入数据，原始数据可能分布不均，经过标准化处理（如零均值归一化）后，数据分布变得更规范、便于模型学习。标准化、归一化等预处理步骤是机器学习第一步，有助于模型更快更好地收敛
    2. 选择优化器，优化器的选择会影响模型训练的速度和最终效果，目的是在损失面上高效地找到最低点
    3. 定义损失函数损失函数的设计和正则化方法直接影响模型泛化能力和决策边界的平滑性
  * 模型无关（Model-agnostic）方法，指的是不依赖于特定模型结构或类型，可以应用于任何机器学习模型的解释或分析方法。换句话说，无论你的模型是决策树、神经网络、支持向量机还是别的，只要能输入和输出，都可以用模型无关方法来解释和分析
  * 后验可解释性：
  1. 局部解释 Feature Importances（特征重要性）说明每个特征对当前决策的贡献有多大。Rule Based（基于规则的）用规则形式（如 if-then 语句）描述模型在某一具体决策时的逻辑。Saliency Maps（显著图）常用于图像任务，突出显示输入中对预测最重要的区域。Prototypes/Example Based（基于原型/样本的）通过与典型样本（prototypes）对比，解释当前样本为什么被分类为某一类。Counterfactuals（反事实解释）指明如果输入稍作改变（如某特征换成别的值），预测会不会不同。
  <br/>
  2. 全局解释 Collection of Local Explanations（局部解释的集合）通过汇总大量单个样本的解释，得到模型整体的解释。Representation Based（基于表示的）分析模型中间层、嵌入空间等整体性表示来解释模型。Model Distillation（模型蒸馏）用一个简单、易解释的模型去拟合复杂模型的决策，从而间接解释复杂模型。Summaries of Counterfactuals（反事实总结）总结不同输入下反事实分析结果，解释模型对变化的整体敏感性。

  评估方法可以从这两个维度，即 模型专用 vs. 模型无关  与  全局解释 vs. 局部解释
  1. LIME  模型无关的，局部的。核心思想是：为了解释复杂模型在某个输入样本上的预测结果，LIME在该样本附近生成大量轻微扰动的邻域样本，用目标模型对这些邻域样本做预测，然后用一个简单的、可解释的线性模型（如稀疏线性回归）拟合这些局部预测结果；这样就能得到这个输入附近，哪个特征对预测影响最大，从而提供局部可解释性。
  2. LEMNA 模型无关的，局部的（使用非线性近似的局部解释）。核心思想是：LEMNA 是 LIME 思路的非线性拓展，用更复杂但仍可解释的模型拟合目标模型的局部行为，从而生成更准确的局部解释。
  3. SHAP 模型无关的，全局的。核心思想是基于合作博弈论中的 Shapley values，把模型预测值视为所有特征“合作”产生的结果，通过计算每个特征在所有可能子集中的边际贡献的平均值，来量化该特征对最终预测的贡献，从而实现全局一致且局部精确的可解释性；它可以适用于任意模型，并保证特征贡献的加和等于模型的实际输出。（即 SHAP 用 Shapley value 衡量特征对预测结果的平均边际贡献，以提供一致、公平的解释。）
  4. 提取决策树，读取决策树的分裂规则，得到整体决策依据。这个方法是模型专用的（不是模型无关），全局解释
  **Q**特征是像素，扰动很小”这个特殊场景下，如何高效地评估像素对模型输出的影响
  ```
  方法
  1.对于每个像素，分别把它加/减一点点，每次都做一次前向传播（forward pass）计算输出，再看输出变化。 缺点：如果图片有成千上万个像素，计算量巨大
  2.只需做一次反向传播（backward pass），就能得到所有像素对输出分数的“微小贡献”（即梯度），利用反向传播的高效性
  ```
  * Integrated Gradients（积分梯度）通过从某个基线输入（如全黑图像、均值图像等）逐步平滑地变成真实输入，在这条路径上累积梯度，这样既能反映出重要特征的真实贡献，又能避免传统梯度解释在某些区域不敏感的问题。
  * CAM： 全局平均池化（GAP）层输出的特征与最后一层卷积特征的权重结合，生成每个类别的激活热力图，可视化模型关注区域。只能用于最后一层特征图和全连接层之间有GAP操作的网络结构，不适合任意结构的深度网络，容易饱和（即所有区域都亮或者都暗），生成“没用的图”。比较简单，易于实现
  * Grad-CAM： Grad-CAM 能将CAM思想推广到任意非线性结构，适用于更广泛的卷积神经网络。对目标类别分数关于特征图做梯度，作为权重加权特征图，实现对关注区域的可视化。适用于任意CNN结构。`步骤`1.求目标类别的分数y^c对特征图A的梯度，得到梯度矩阵2. 全局平均梯度：对每个特征图的梯度在空间维度求平均3.加权特征图：将权重与特征图相乘并求和，得到粗热力图
  * Prototype-based 基于原型的方法，影响函数（Influence function），目标是识别最能影响某个预测结果的训练样本
  * 定义`缺失特征`,有时候也会有缺点，比如遇到黑色汽车，灰色的物品什么的，巴拉巴拉。可以通过`有意义的扰动`解决,把关键点抹掉
    *   Integrated gradients：把0（黑色像素）作为“缺失特征”。
    *   Zintgraf et al：用填补/修补（inpainting）的方法来模拟缺失特征。
    *   LIME：用均值（灰色像素）表示缺失特征。
    *   Shapley：同样用均值（灰色像素）作为缺失特征。
  ### 8.2. 公平性
  * 群体公平,可能导致模型可用性很差
  * 准确率公平，每个群体被准确预测（预测值等于真实值）的概率是一样的。虽然整体准确率一样，但“错误类型”不同（假阳性/假阴性）仍会造成实际不公平。
  * Equal Opportunity（机会均等）TPP
  * FPP
  * TPP + FPP = Equalized Odds（机会均等）
  ## 9. 应用层安全
  ### 9.1. 移动端智能模型的要求
  ```
  要求低延时
    自动驾驶
    扫地机器人导航避障
  要求离线使用
    偏远地区电力巡检
    对云端服务器负载过大
    支付宝将扫五福功能由云端移到终端执行[1]
  要求保护隐私
    GDPR要求个人生物识别信息存储在本地，并在本地处理[2]
    人脸识别，指纹识别等
  ```
  ### 9.2. 移动端模型特点
  * 模型结构较简单,以CNN居多,大部分是32位浮点数计算
  * 运行开销小
  ### 9.3. 移动端模型优势
  * 延迟：不需要通过网络连接发送请求并等待响应。
  * 可用性：即使在网络覆盖范围之外，应用也能运行。
  * 速度：专用于神经网络处理的新硬件提供的计算速度明显快于单纯的通用CPU。
  * 隐私：数据不会离开Android设备。
  * 费用：所有计算都在Android设备上执行，不需要额外的云服务器。
  * 个性化（可扩展性）：可以为用户定制机器学习服务。
  ### 9.4. 移动端模型优化
  * 权重量化:指用低位宽表示类型为32位浮点同构参数。网络参数包括权重、激活值、梯度和误差等量，可使用统一的位宽（如16-bit、8-bit、2-bit和1-bit等）。
  * 权重稀疏化:通过对网络权重引入稀疏性约束，可以大幅度降低网络权重中的非零元素个数；压缩后模型的网络权重可以以稀疏矩阵的形式进行存储和传输，从而实现模型压缩。
  * 通道剪枝:在CNN网络中，通过对特征图中的通道维度进行剪枝，可以同时降低模型大小和计算复杂度。
  * 网络蒸馏:通过将未压缩的原始模型的输出作为额外的监督信息，指导压缩后模型的训练。
  ### 9.5. 数据安全
  #### 数据隐私安全风险
  * 人工智能的开发、 测试、 运行过程中存在的隐私侵犯问题。
  #### 数据质量安全风险
  * 用于人工智能的训练数据集以及采集的现场数据潜在存在的质量问题。
  * 投毒攻击：试图通过污染训练数据来降低深度学习系统的预测
  #### 数据保护安全风险
  * 人工智能开发及应用企业对持有数据的全生命周期安全保护问题。
  * 成员推理攻击：给定数据记录和模型的黑盒访问权限，确定该记录是否在模型的训练数据集中
  #### 算法设计安全风险
  * 在算法或实施过程有误可产生与预期不符甚至伤害性结果。
  * 对抗样本：在数据集中通过故意添加细微的干扰所形成的输入样本，会导致模型以高置信度给出一个错误的输出。
  #### 算法黑箱安全风险
  * 基于神经网络的深度学习算法，通过复杂的计算过程对输入数据进行计算，人们依据现有的科学知识和原理对输出的结果难以解释。
  #### 算法偏见歧视风险
  * 在信息生产和分发过程失去客观中立的立场，影响公众对信息的客观全面认知，或者在智能决策中，通过排序、分类、关联和过滤产生不公平问题。
  * 主要表现为价格歧视、性别歧视、种族歧视。
  ### 模型参数安全
  * 明文模型：加载判断，十六进制判断
  * 保护措施：混淆，调用代码混淆，模型调用功能在native层实现，完整性检验(无法阻止模型窃取)，动态下载(api接口保护)，自定义OP，水印，闭源框架，加密(无法对抗内存dump)
  * 张量 Tensor，对张量的不当处理可能引发问题
  * 底层软件的安全，相应库的漏洞
  ......
  ## 10. 框架层安全
  ### 10.1. 框架缺陷
  * 指机器学习框架代码中存在问题、缺陷，致使学习框架在训练或者推理时出现不满足预期的行为。
  * 在机器学习框架进行训练或者推理时， 需要解析数据集或者加载模型文件，相关过程都有可能存在异常行为。
  * 框架缺陷类型包括内存非法访问越界、空指针引用、整数溢出等，危害性涉及信息泄露、拒绝服务、任意代码执行等。
  * 此外，在学习框架中，框架缺陷还包括精度丢失，使得 AI 服务无法满足预期要求。
  ### 10.2. 终端机器学习推理框架
  终端机器学习推理框架分为以下两部分：

  * 终端模型文件解析：框架通过模型文件中保存的网络拓扑信息， 构建计算图。
  * 机器学习推理：框架通过用户输入数据，使用计算图进行推理， 计算最终的结果。

  终端框架中封装了大量计算操作的算子实现，如卷积操作、池化操作、系数操作等
  ### 10.3. 底层软件安全
  * AI系统依赖于大量底层软件框架及各种类运行库的支持
  * AI系统与上百个例如Numpy, openCV等第三方运行库进行交互
  * 这些库及相关依赖中隐藏的安全漏洞将影响AI系统的整体安全
  * 这些图像/视频处理库、矩阵计算库等等，存在包括拒绝服务Dos，堆溢出，整数溢出等各种不同的漏洞类型
  ### 10.4. 数据劫持
  • 指在数据采集、传输、使用过程中，通过对设备硬件、操作系统、应用程序或网络链路，使用注入、替换等技术拦截或篡改数据。
  • 例如在人脸识别场景，把本该从实际摄像头获取的视频流数据改为读取指定的视频文件对算法进行攻击。
  • 此类攻击属于设备底层技术篡改风险， 攻击者通过数据劫持技术，对模型注入通过非法渠道采集或购买的真实数据，进而绕过 AI 模型对深度伪造和对抗攻击的防护，实无感攻击，具有技术成熟、使用方法简单、隐蔽性强、检测难度大等特点。
  ## 11. 供应链安全
  指AI模型及其相关依赖（数据、代码、模型、库等）在开发、传输、部署等全流程中可能遭受的攻击与威胁。
