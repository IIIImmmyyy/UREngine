# UREngine 代码还原示例

[项目介绍](./README-ch.md) · [English](./README.md) · [官方网站](https://www.ur-engine.com/) · [下载 Studio](https://github.com/IIIImmmyyy/UREngine/releases/latest)

UREngine 将 Unity IL2CPP 原生代码与元数据恢复为便于浏览、搜索和审阅的 C# 工程。Studio 提供任务提交、结果下载与代码/资源浏览入口。

下方保留早期代码还原对比资料，用于展示输出形式，不代表所有输入都能获得相同结果。当前支持范围与已知限制请参阅[官网](https://www.ur-engine.com/support/)；如需参与内测，请提交[内测申请](https://www.ur-engine.com/trial/)，审核通过后获得激活授权。公开版 Studio 暂未开放 Unity 工程导出。

## 代码对比

```csharp
UREngine反编译出来的代码：

/// <summary>
/// Decompiled IL2CPP By Imy-UREngine 🥰
/// </summary>
public class UIAvatar : MonoBehaviour
{
    public GameObject touchRect;
    private UGUIEventListener event_down;
    private UGUIEventListener event_drag;
    private float point_X;
    public float rotateSpeed;
    private Transform transform_;
    private bool isDrag;
    private void AddEvent()
    {
        if (!(touchRect == null))
        {
            event_down = UGUIEventListener.Get(touchRect);
            event_down.onDown = TouchDown;
            event_drag = UGUIEventListener.Get(touchRect);
            event_drag.onDrag = TouchDrag;
        }
    }

    private void TouchDown(GameObject go)
    {
        isDrag = true;
        point_X = Input.mousePosition.x;
    }

    private void TouchDrag(GameObject go)
    {
        if (isDrag)
        {
            Transform obj = transform_;
            obj.localRotation = Quaternion.Euler(0f, obj.localRotation.eulerAngles.y - (Input.mousePosition.x - point_X) * rotateSpeed, 0f);
            point_X = Input.mousePosition.x;
        }
    }
}
```

```c++
IDA Pro反编译出来的代码：
void __fastcall UIAvatar__TouchDrag(UIAvatar_o *this, UnityEngine_GameObject_o *go, const MethodInfo *method)
{
  UnityEngine_Transform_o *transform; // x20
  UnityEngine_Vector3_o v5; // 0:s0.4,4:s1.4,8:s2.4
  UnityEngine_Vector3_o Positive; // 0:s0.4,4:s1.4,8:s2.4
  UnityEngine_Vector3_o v7; // 0:s0.4,4:s1.4,8:s2.4
  UnityEngine_Quaternion_o localRotation; // 0:s0.4,4:s1.4,8:s2.4,12:s3.4
  UnityEngine_Quaternion_o v9; // 0:s0.4,4:s1.4,8:s2.4,12:s3.4

  if ( this->fields.isDrag )
  {
    transform = this->fields.transform_;
    if ( !transform )
      sub_11752B8();
    localRotation = UnityEngine_Transform__get_localRotation(this->fields.transform_, 0LL);
    v5 = UnityEngine_Quaternion__Internal_ToEulerRad(localRotation, 0LL);
    v5.fields.x = v5.fields.x * 57.296;
    v5.fields.y = v5.fields.y * 57.296;
    v5.fields.z = v5.fields.z * 57.296;
    Positive = UnityEngine_Quaternion__Internal_MakePositive(v5, 0LL);
    v7.fields.y = (float)(Positive.fields.y
                        - (float)((float)(COERCE_FLOAT(UnityEngine_Input__get_mousePosition(0LL)) - this->fields.point_X)
                                * this->fields.rotateSpeed))
                * 0.017453;
    v7.fields.x = 0.0;
    v7.fields.z = 0.0;
    v9 = UnityEngine_Quaternion__Internal_FromEulerRad(v7, 0LL);
    UnityEngine_Transform__set_localRotation(transform, v9, 0LL);
    LODWORD(this->fields.point_X) = (unsigned int)UnityEngine_Input__get_mousePosition(0LL);
  }
}
```

```csharp
UREngine反编译出来的代码：
 private void MoveSpecificBullet(Vector3 v3TargetPos, float time)
    {
        Vector3 localPosition = m_rtrTrans.localPosition;
        RectTransform rtrTrans = m_rtrTrans;
        v3PosSaved = localPosition;
        Vector3 up = rtrTrans.up;
        float fSpeed = m_fSpeed;
        Vector3 position = m_rtrTrans.position;
        RectTransform rtrTrans2 = m_rtrTrans;
        float num = fSpeed * time;
        if (!(Vector3.Magnitude(up * num) * 0.1f <= Vector3.Distance(position, v3TargetPos)))
            rtrTrans2.position = v3TargetPos;
        else
        {
            rtrTrans2.localPosition += up * num;
            float y = v3CurPos.y;
            if (!(y < 0f) && !(y > m_Exe_Height))
            {
                y = v3CurPos.x;
                if (!(y < 0f) && y <= m_Exe_Width)
                {
                    v3CurPos = m_rtrTrans.localPosition;
                    return;
                }
            }
        }

        AcMoveDoneCallBack?.Invoke();
    }

```

```c++
IDA Pro反编译出来的代码：
// local variable allocation has failed, the output may be wrong!
void __fastcall BulletMove__MoveSpecificBullet(
        BulletMove_o *this,
        UnityEngine_Vector3_o v3TargetPos,
        float time,
        const MethodInfo *method)
{
  UnityEngine_Transform_o *m_rtrTrans; // x0
  float z; // s14
  float y; // s10
  float x; // s13
  UnityEngine_Transform_o *v10; // x0
  float m_fSpeed; // s9
  UnityEngine_Transform_o *v12; // x0
  float v13; // s15
  float v14; // s8
  float v15; // s11
  UnityEngine_Transform_o *v16; // x20
  float v17; // s6
  float v18; // s3
  float v19; // s11
  float v20; // s4
  float v21; // s9
  float v22; // s8
  UnityEngine_Transform_o *v23; // x0
  float v24; // s0
  float v25; // s0
  struct System_Action_o *AcMoveDoneCallBack; // x8
  UnityEngine_Transform_o *v27; // x0
  float v28; // [xsp+4h] [xbp-6Ch]
  float v29; // [xsp+8h] [xbp-68h]
  float v30; // [xsp+Ch] [xbp-64h]
  UnityEngine_Vector3_o localPosition; // 0:s0.4,4:s1.4,8:s2.4
  UnityEngine_Vector3_o up; // 0:s0.4,4:s1.4,8:s2.4
  UnityEngine_Vector3_o position; // 0:s0.4,4:s1.4,8:s2.4
  UnityEngine_Vector3_o v34; // 0:s0.4,4:s1.4,8:s2.4
  UnityEngine_Vector3_o v35; // 0:s0.4,4:s1.4,8:s2.4

  m_rtrTrans = (UnityEngine_Transform_o *)this->fields.m_rtrTrans;
  if ( !m_rtrTrans )
    goto LABEL_25;
  z = v3TargetPos.fields.z;
  y = v3TargetPos.fields.y;
  x = v3TargetPos.fields.x;
  localPosition = UnityEngine_Transform__get_localPosition(m_rtrTrans, 0LL);
  v10 = (UnityEngine_Transform_o *)this->fields.m_rtrTrans;
  this->fields.v3PosSaved = localPosition;
  if ( !v10 )
    goto LABEL_25;
  up = UnityEngine_Transform__get_up(v10, 0LL);
  m_fSpeed = this->fields.m_fSpeed;
  v29 = up.fields.y;
  v30 = up.fields.x;
  v28 = up.fields.z;
  if ( !byte_2C63B6E )
  {
    sub_117506C(&System_Math_TypeInfo);
    byte_2C63B6E = 1;
  }
  if ( !System_Math_TypeInfo->_2.cctor_finished )
    sub_11751A0(System_Math_TypeInfo);
  v12 = (UnityEngine_Transform_o *)this->fields.m_rtrTrans;
  if ( !v12 )
    goto LABEL_25;
  position = UnityEngine_Transform__get_position(v12, 0LL);
  v13 = position.fields.x;
  v14 = position.fields.y;
  v15 = position.fields.z;
  if ( !byte_2C63B6D )
  {
    sub_117506C(&System_Math_TypeInfo);
    byte_2C63B6D = 1;
  }
  if ( !System_Math_TypeInfo->_2.cctor_finished )
    sub_11751A0(System_Math_TypeInfo);
  v16 = (UnityEngine_Transform_o *)this->fields.m_rtrTrans;
  if ( !v16 )
    goto LABEL_25;
  v17 = m_fSpeed * time;
  v18 = v15 - z;
  v19 = v30 * (float)(m_fSpeed * time);
  v20 = v14 - y;
  v21 = v29 * (float)(m_fSpeed * time);
  v22 = v28 * v17;
  if ( (float)(sqrtf((float)(v22 * v22) + (float)((float)(v19 * v19) + (float)(v21 * v21))) * 0.1) <= sqrtf((float)(v18 * v18) + (float)((float)((float)(v13 - x) * (float)(v13 - x)) + (float)(v20 * v20))) )
  {
    v35 = UnityEngine_Transform__get_localPosition((UnityEngine_Transform_o *)this->fields.m_rtrTrans, 0LL);
    v35.fields.x = v19 + v35.fields.x;
    v35.fields.y = v21 + v35.fields.y;
    v35.fields.z = v22 + v35.fields.z;
    UnityEngine_Transform__set_localPosition(v16, v35, 0LL);
    v23 = (UnityEngine_Transform_o *)this->fields.m_rtrTrans;
    if ( v23 )
    {
      UnityEngine_Transform__get_position(v23, 0LL);
      v24 = this->fields.v3CurPos.fields.y;
      if ( v24 < 0.0 )
        goto LABEL_20;
      if ( v24 > this->fields.m_Exe_Height )
        goto LABEL_20;
      v25 = this->fields.v3CurPos.fields.x;
      if ( v25 < 0.0 || v25 > this->fields.m_Exe_Width )
        goto LABEL_20;
      v27 = (UnityEngine_Transform_o *)this->fields.m_rtrTrans;
      if ( v27 )
      {
        this->fields.v3CurPos = UnityEngine_Transform__get_localPosition(v27, 0LL);
        return;
      }
    }
LABEL_25:
    sub_11752B8();
  }
  v34.fields.x = x;
  v34.fields.y = y;
  v34.fields.z = z;
  UnityEngine_Transform__set_position((UnityEngine_Transform_o *)this->fields.m_rtrTrans, v34, 0LL);
LABEL_20:
  AcMoveDoneCallBack = this->fields.AcMoveDoneCallBack;
  if ( AcMoveDoneCallBack )
    ((void (__fastcall *)(struct System_Reflection_MethodInfo_o *, _QWORD))AcMoveDoneCallBack->fields.m_target)(
      AcMoveDoneCallBack->fields.original_method_info,
      *(_QWORD *)&AcMoveDoneCallBack->fields.extra_arg);
}
```
