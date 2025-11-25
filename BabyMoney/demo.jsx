import React, { useState, useEffect } from 'react';
import { 
  Rabbit, Coins, Lock, Plus, Minus, Settings, X, ChevronLeft, History, Star, 
  Gamepad2, Utensils, Shirt, BookOpen, Package, PieChart, Sparkles, MessageCircle, Loader2 
} from 'lucide-react';

// --- Gemini API 配置 ---
const apiKey = ""; // 系统会自动注入 API Key

const callGemini = async (prompt) => {
  try {
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-09-2025:generateContent?key=${apiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }]
        })
      }
    );
    const data = await response.json();
    return data.candidates?.[0]?.content?.parts?.[0]?.text || "小兔子正在打瞌睡，请稍后再试...";
  } catch (error) {
    console.error("Gemini API Error:", error);
    return "网络有点卡，小兔子听不清...";
  }
};

// --- 初始数据与配置 ---
const DEFAULT_PIN = "0000"; 

const INITIAL_USERS = [
  { id: 'u1', name: '姐姐', color: 'bg-pink-100', text: 'text-pink-600', border: 'border-pink-300', iconColor: '#db2777', balance: 50 },
  { id: 'u2', name: '妹妹', color: 'bg-purple-100', text: 'text-purple-600', border: 'border-purple-300', iconColor: '#9333ea', balance: 50 }
];

const CATEGORIES = [
  { id: 'toy', name: '玩具', icon: Gamepad2, color: 'text-blue-500', bg: 'bg-blue-100', chartColor: '#3b82f6' },
  { id: 'food', name: '零食', icon: Utensils, color: 'text-orange-500', bg: 'bg-orange-100', chartColor: '#f97316' },
  { id: 'clothes', name: '衣服', icon: Shirt, color: 'text-purple-500', bg: 'bg-purple-100', chartColor: '#a855f7' },
  { id: 'book', name: '书本', icon: BookOpen, color: 'text-green-500', bg: 'bg-green-100', chartColor: '#22c55e' },
  { id: 'other', name: '其他', icon: Package, color: 'text-gray-500', bg: 'bg-gray-100', chartColor: '#9ca3af' },
];

// --- 工具组件 ---

const NumPad = ({ onInput, onDelete, onConfirm, confirmText = "确定" }) => {
  const nums = [1, 2, 3, 4, 5, 6, 7, 8, 9, '.', 0, 'DEL'];
  return (
    <div className="grid grid-cols-3 gap-3 w-full max-w-xs mx-auto mt-4">
      {nums.map((n) => (
        <button
          key={n}
          onClick={() => n === 'DEL' ? onDelete() : onInput(n)}
          className={`h-16 text-2xl font-bold rounded-2xl shadow-sm active:scale-95 transition-transform flex items-center justify-center
            ${n === 'DEL' ? 'bg-red-50 text-red-500' : 'bg-white text-gray-700'}`}
        >
          {n === 'DEL' ? <X size={24} /> : n}
        </button>
      ))}
      <button 
        onClick={onConfirm}
        className="col-span-3 mt-2 h-16 bg-green-500 hover:bg-green-600 text-white text-xl font-bold rounded-2xl shadow-md active:scale-95 transition-all"
      >
        {confirmText}
      </button>
    </div>
  );
};

const SimplePieChart = ({ data }) => {
  const total = data.reduce((acc, item) => acc + item.value, 0);
  let cumulativePercent = 0;

  if (total === 0) {
    return (
      <div className="w-48 h-48 rounded-full bg-gray-100 flex items-center justify-center text-gray-400 text-sm">
        暂无数据
      </div>
    );
  }

  return (
    <div className="relative w-48 h-48">
      <svg viewBox="-1 -1 2 2" className="w-full h-full rotate-[-90deg]">
        {data.map((slice, i) => {
          const startPercent = cumulativePercent;
          const slicePercent = slice.value / total;
          cumulativePercent += slicePercent;
          const endPercent = cumulativePercent;

          const getCoords = (percent) => ({
            x: Math.cos(2 * Math.PI * percent),
            y: Math.sin(2 * Math.PI * percent)
          });

          const start = getCoords(startPercent);
          const end = getCoords(endPercent);
          const largeArcFlag = slicePercent > 0.5 ? 1 : 0;

          if (slicePercent === 1) {
             return <circle key={i} cx="0" cy="0" r="1" fill={slice.color} />
          }

          return (
            <path
              key={i}
              d={`M 0 0 L ${start.x} ${start.y} A 1 1 0 ${largeArcFlag} 1 ${end.x} ${end.y} Z`}
              fill={slice.color}
              stroke="white"
              strokeWidth="0.05"
            />
          );
        })}
      </svg>
      <div className="absolute inset-0 m-auto w-24 h-24 bg-white rounded-full flex items-center justify-center shadow-inner">
         <span className="text-gray-500 font-bold text-sm">总支出<br/>¥{total}</span>
      </div>
    </div>
  );
};

// --- Gemini 功能组件: 智慧兔兔 ---
const WiseRabbitWidget = ({ user, transactions }) => {
  const [advice, setAdvice] = useState("");
  const [loading, setLoading] = useState(false);

  const askRabbit = async () => {
    setLoading(true);
    setAdvice("");
    
    // 准备发送给 AI 的数据
    const recentTrans = transactions
      .slice(0, 5)
      .map(t => `${t.type === 'in' ? '存入' : '支出'}${t.amount}元${t.categoryId ? '(' + CATEGORIES.find(c=>c.id===t.categoryId)?.name + ')' : ''}`)
      .join(", ");

    const prompt = `
      你是一个专门教4岁小朋友理财的可爱魔法兔子。
      小朋友名字叫：${user.name}。
      当前余额：${user.balance}元。
      最近5笔交易：${recentTrans || "无"}。
      
      请根据以上信息，用充满童趣、鼓励或温和提醒的语气，对小朋友说一句话（30个字以内）。
      如果是存钱多了，就夸奖她；如果花钱在零食或玩具多了，就温柔提醒她要存钱。
      必须使用中文，可以加emoji。
    `;

    const result = await callGemini(prompt);
    setAdvice(result);
    setLoading(false);
  };

  return (
    <div className="bg-gradient-to-r from-indigo-50 to-purple-50 rounded-2xl p-4 shadow-sm border border-indigo-100 mb-6">
      <div className="flex items-start gap-3">
        <div className="bg-white p-2 rounded-full shadow-sm">
           <MessageCircle className="text-indigo-500" size={24} />
        </div>
        <div className="flex-1">
          <h4 className="font-bold text-indigo-800 flex items-center gap-2">
            智慧兔兔说
            {!advice && !loading && (
              <button 
                onClick={askRabbit}
                className="text-xs bg-indigo-500 text-white px-2 py-1 rounded-full flex items-center gap-1 hover:bg-indigo-600 transition-colors animate-pulse"
              >
                <Sparkles size={12} /> 点击召唤
              </button>
            )}
          </h4>
          
          <div className="mt-2 min-h-[40px] text-sm text-indigo-700 font-medium leading-relaxed">
            {loading ? (
              <div className="flex items-center gap-2 text-gray-400">
                <Loader2 className="animate-spin" size={16} /> 
                兔兔正在思考...
              </div>
            ) : (
              advice || "点一点上面的按钮，听听兔兔给你什么建议吧！"
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

// --- Gemini 功能组件: 魔法分析 ---
const AIMagicReport = ({ user, period, categoryData }) => {
  const [report, setReport] = useState("");
  const [loading, setLoading] = useState(false);

  const generateReport = async () => {
    setLoading(true);
    
    const summary = categoryData.map(c => `${c.name}花了${c.value}元`).join("，");
    
    const prompt = `
      你是一个亲切的家庭理财顾问，对象是4岁的孩子${user.name}。
      时间范围：${period === 'month' ? '本月' : '今年'}。
      消费数据：${summary || "没有花钱"}。
      
      请生成一段简短的“魔法分析报告”（50字以内）。
      用讲故事的口吻总结她的消费习惯。例如：“哇，这个月我们在玩具上花了很多金币哦！”
      最后给出一个小小的建议。
    `;

    const result = await callGemini(prompt);
    setReport(result);
    setLoading(false);
  };

  return (
    <div className="bg-white rounded-[2rem] p-6 shadow-xl mb-8 border-2 border-yellow-100 relative overflow-hidden">
       <div className="absolute top-0 right-0 p-4 opacity-10">
         <Sparkles size={100} className="text-yellow-400" />
       </div>
       
       <h3 className="text-yellow-600 font-bold mb-4 flex items-center gap-2">
         <Sparkles size={20} /> 魔法分析报告
       </h3>
       
       <div className="bg-yellow-50 rounded-xl p-4 text-gray-700 leading-relaxed font-medium">
         {loading ? (
            <div className="flex justify-center py-4">
              <Loader2 className="animate-spin text-yellow-500" size={24} />
            </div>
         ) : (
           report || "点击下方按钮，施展魔法看看你的消费习惯吧！"
         )}
       </div>
       
       <button 
         onClick={generateReport}
         disabled={loading}
         className="w-full mt-4 bg-yellow-400 hover:bg-yellow-500 text-white font-bold py-3 rounded-xl flex items-center justify-center gap-2 transition-all active:scale-95 disabled:opacity-50"
       >
         {loading ? "魔法生成中..." : "✨ 生成魔法报告 ✨"}
       </button>
    </div>
  );
};

// --- 主应用组件 ---
export default function BunnyBankApp() {
  const [users, setUsers] = useState(INITIAL_USERS);
  const [transactions, setTransactions] = useState([]); 
  const [view, setView] = useState('home'); 
  const [currentUser, setCurrentUser] = useState(null);
  const [modalMode, setModalMode] = useState(null); 
  const [inputVal, setInputVal] = useState("");
  const [tempAuthAction, setTempAuthAction] = useState(null); 
  const [weeklyAllowance, setWeeklyAllowance] = useState(20);
  const [spendStep, setSpendStep] = useState('amount'); 
  const [analysisPeriod, setAnalysisPeriod] = useState('month'); 

  useEffect(() => {
    const savedUsers = localStorage.getItem('bunny_users');
    const savedTrans = localStorage.getItem('bunny_trans');
    if (savedUsers) setUsers(JSON.parse(savedUsers));
    if (savedTrans) setTransactions(JSON.parse(savedTrans));
  }, []);

  useEffect(() => {
    localStorage.setItem('bunny_users', JSON.stringify(users));
    localStorage.setItem('bunny_trans', JSON.stringify(transactions));
  }, [users, transactions]);

  // --- 逻辑处理 ---
  const selectUser = (user) => {
    setCurrentUser(user);
    setView('dashboard');
  };

  const goHome = () => {
    setView('home');
    setCurrentUser(null);
    setModalMode(null);
    setInputVal("");
    setSpendStep('amount');
  };

  const handleAuth = () => {
    if (inputVal === DEFAULT_PIN) {
      setInputVal("");
      setModalMode(null);
      if (tempAuthAction) {
        tempAuthAction();
        setTempAuthAction(null);
      }
    } else {
      alert("密码错误哦！只有爸爸妈妈才能操作。");
      setInputVal("");
    }
  };

  const requireAuth = (callback) => {
    setTempAuthAction(() => callback);
    setModalMode('auth');
  };

  const handleTransaction = (type, categoryId = null) => {
    const amount = parseFloat(inputVal);
    if (isNaN(amount) || amount <= 0) return;

    if (type === 'out' && currentUser.balance < amount) {
      alert("余额不足啦！");
      return;
    }

    const newUsers = users.map(u => {
      if (u.id === currentUser.id) {
        return { ...u, balance: type === 'in' ? u.balance + amount : u.balance - amount };
      }
      return u;
    });
    setUsers(newUsers);

    const newTrans = {
      id: Date.now(),
      userId: currentUser.id,
      amount: amount,
      type: type,
      categoryId: categoryId,
      date: new Date().toLocaleDateString(),
      rawDate: new Date().toISOString(),
      time: new Date().toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})
    };
    setTransactions([newTrans, ...transactions]);
    setCurrentUser(newUsers.find(u => u.id === currentUser.id));
    
    setModalMode(null);
    setInputVal("");
    setSpendStep('amount');
  };

  const giveAllowance = () => {
    setInputVal(weeklyAllowance.toString());
    handleTransaction('in', 'allowance');
  };

  const handleNumInput = (v) => {
    if (v === '.' && inputVal.includes('.')) return;
    if (inputVal.length > 5) return;
    setInputVal(prev => prev + v);
  };

  const openSpendModal = () => {
    setSpendStep('amount');
    setModalMode('spend');
  };

  const handleSpendAmountConfirm = () => {
     if (!inputVal || parseFloat(inputVal) <= 0) return;
     if (parseFloat(inputVal) > currentUser.balance) {
       alert('钱不够买这个东西哦！');
       return;
     }
     setSpendStep('category');
  };

  const getCategoryDetails = (id) => {
      return CATEGORIES.find(c => c.id === id) || CATEGORIES.find(c => c.id === 'other');
  };

  // --- 渲染部分 ---

  if (view === 'home') {
    return (
      <div className="min-h-screen bg-orange-50 flex flex-col items-center justify-center p-6 font-sans">
        <h1 className="text-4xl md:text-5xl font-extrabold text-orange-400 mb-12 flex items-center gap-3">
          <Rabbit size={48} className="animate-bounce" />
          宝宝存钱罐
        </h1>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 w-full max-w-4xl">
          {users.map(user => (
            <button
              key={user.id}
              onClick={() => selectUser(user)}
              className={`relative group transform transition-all duration-300 hover:-translate-y-2 active:scale-95
                bg-white rounded-[3rem] p-8 shadow-xl border-4 ${user.border} flex flex-col items-center justify-center gap-6 h-80`}
            >
              <div className={`p-6 rounded-full ${user.color} mb-2`}>
                <Rabbit size={80} color={user.iconColor} strokeWidth={1.5} />
              </div>
              <span className={`text-4xl font-bold ${user.text}`}>{user.name}</span>
              <div className="absolute bottom-6 bg-gray-100 px-4 py-1 rounded-full text-gray-500 text-sm font-medium">
                点击进入
              </div>
            </button>
          ))}
        </div>
      </div>
    );
  }

  if (view === 'analysis') {
    const now = new Date();
    const filteredTrans = transactions.filter(t => {
      if (t.userId !== currentUser.id || t.type !== 'out') return false;
      const tDate = new Date(t.rawDate);
      if (analysisPeriod === 'month') {
        return tDate.getMonth() === now.getMonth() && tDate.getFullYear() === now.getFullYear();
      } else {
        return tDate.getFullYear() === now.getFullYear();
      }
    });

    const categoryData = CATEGORIES.map(cat => {
      const value = filteredTrans
        .filter(t => t.categoryId === cat.id)
        .reduce((sum, t) => sum + t.amount, 0);
      return { ...cat, value };
    }).filter(item => item.value > 0).sort((a, b) => b.value - a.value);

    const pieData = categoryData.map(c => ({ color: c.chartColor, value: c.value }));

    return (
      <div className={`min-h-screen ${currentUser.color}`}>
         <div className="p-6 flex items-center gap-4">
           <button onClick={() => setView('dashboard')} className="bg-white p-3 rounded-full shadow-md text-gray-600 hover:bg-gray-50">
             <ChevronLeft size={32} />
           </button>
           <h2 className={`text-3xl font-bold ${currentUser.text}`}>消费小侦探</h2>
         </div>

         <div className="max-w-4xl mx-auto px-4 pb-12">
            <div className="flex bg-white/50 p-1 rounded-xl mb-8 w-max mx-auto">
               <button 
                 onClick={() => setAnalysisPeriod('month')}
                 className={`px-6 py-2 rounded-lg font-bold transition-all ${analysisPeriod === 'month' ? 'bg-white shadow-sm text-gray-800' : 'text-gray-500'}`}
               >
                 这个月
               </button>
               <button 
                 onClick={() => setAnalysisPeriod('year')}
                 className={`px-6 py-2 rounded-lg font-bold transition-all ${analysisPeriod === 'year' ? 'bg-white shadow-sm text-gray-800' : 'text-gray-500'}`}
               >
                 今年
               </button>
            </div>

            {/* AI 魔法报告区域 */}
            <AIMagicReport user={currentUser} period={analysisPeriod} categoryData={categoryData} />

            <div className="grid md:grid-cols-2 gap-8">
               <div className="bg-white rounded-[2rem] p-8 shadow-xl flex flex-col items-center">
                  <h3 className="text-gray-500 font-bold mb-6">钱都花去哪了？</h3>
                  <SimplePieChart data={pieData} />
                  {pieData.length === 0 && <p className="mt-4 text-gray-400">这个时间段没有花钱哦，真棒！</p>}
               </div>

               <div className="bg-white rounded-[2rem] p-8 shadow-xl">
                 <h3 className="text-gray-500 font-bold mb-6">消费排行榜</h3>
                 <div className="space-y-4">
                    {categoryData.length > 0 ? categoryData.map((item, idx) => {
                       const Icon = item.icon;
                       return (
                         <div key={item.id} className="flex items-center gap-4">
                           <div className="font-bold text-gray-300 w-6">#{idx + 1}</div>
                           <div className={`p-3 rounded-2xl ${item.bg} ${item.color}`}>
                              <Icon size={24} />
                           </div>
                           <div className="flex-1">
                             <div className="font-bold text-gray-700">{item.name}</div>
                             <div className="h-2 bg-gray-100 rounded-full mt-1 overflow-hidden">
                               <div style={{width: `${(item.value / pieData.reduce((a,b)=>a+b.value,0)) * 100}%`}} className={`h-full ${item.bg.replace('bg-', 'bg-opacity-100 bg-')}`}></div>
                             </div>
                           </div>
                           <div className="font-bold text-gray-800">¥{item.value}</div>
                         </div>
                       )
                    }) : (
                      <div className="text-center text-gray-400 py-4">暂无数据</div>
                    )}
                 </div>
               </div>
            </div>
         </div>
      </div>
    );
  }

  const userTrans = transactions.filter(t => t.userId === currentUser.id);

  return (
    <div className={`min-h-screen ${currentUser.color} transition-colors duration-500`}>
      <div className="p-6 flex justify-between items-center">
        <button onClick={goHome} className="bg-white p-3 rounded-full shadow-md text-gray-600 hover:bg-gray-50">
          <ChevronLeft size={32} />
        </button>
        <div className="flex items-center gap-3 bg-white/80 backdrop-blur px-6 py-2 rounded-full shadow-sm">
          <Rabbit size={32} color={currentUser.iconColor} />
          <span className={`text-2xl font-bold ${currentUser.text}`}>{currentUser.name}的账户</span>
        </div>
        <div className="flex gap-2">
           <button 
             onClick={() => setView('analysis')} 
             className="bg-white p-3 rounded-full shadow-md text-blue-500 hover:text-blue-600"
             title="消费分析"
           >
            <PieChart size={28} />
          </button>
          <button 
            onClick={() => requireAuth(() => setModalMode('settings'))} 
            className="bg-white p-3 rounded-full shadow-md text-gray-400 hover:text-gray-600"
          >
            <Settings size={28} />
          </button>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 mt-4">
        
        {/* Gemini 智慧兔兔组件 */}
        <WiseRabbitWidget user={currentUser} transactions={userTrans} />

        <div className="bg-white rounded-[3rem] p-10 shadow-xl text-center relative overflow-hidden border-4 border-white/50">
            <div className="absolute top-0 left-0 w-full h-4 bg-gray-100/50"></div>
            <p className="text-gray-400 text-xl font-medium mb-4">现在有这么多钱</p>
            <div className="flex items-center justify-center gap-2 text-7xl md:text-9xl font-extrabold text-gray-800 tracking-tight my-4">
              <span className="text-4xl text-gray-400 mt-4">¥</span>
              {currentUser.balance.toFixed(2)}
            </div>
            
            <div className="grid grid-cols-2 gap-6 mt-10 max-w-lg mx-auto">
              <button
                onClick={openSpendModal}
                className="bg-red-100 hover:bg-red-200 border-2 border-red-200 text-red-500 rounded-3xl p-6 flex flex-col items-center gap-3 transition-colors shadow-sm active:scale-95"
              >
                <div className="bg-white p-4 rounded-full shadow-sm">
                  <Minus size={32} />
                </div>
                <span className="text-2xl font-bold">我要花钱</span>
              </button>

              <button
                onClick={() => requireAuth(() => setModalMode('add'))}
                className="bg-green-100 hover:bg-green-200 border-2 border-green-200 text-green-600 rounded-3xl p-6 flex flex-col items-center gap-3 transition-colors shadow-sm active:scale-95"
              >
                <div className="bg-white p-4 rounded-full shadow-sm">
                  <Plus size={32} />
                </div>
                <span className="text-2xl font-bold">家长存钱</span>
              </button>
            </div>
        </div>

        <div className="mt-8 bg-white/60 backdrop-blur rounded-[2rem] p-6 shadow-lg mb-10">
          <h3 className="text-xl text-gray-600 font-bold mb-4 flex items-center gap-2 px-2">
            <History size={24} /> 最近的收支
          </h3>
          <div className="space-y-3">
            {userTrans.length === 0 ? (
              <div className="text-center py-8 text-gray-400">
                还没有花钱记录哦，小兔子存钱罐空空的~
              </div>
            ) : (
              userTrans.slice(0, 5).map(t => {
                const isOut = t.type === 'out';
                const catInfo = isOut && t.categoryId ? getCategoryDetails(t.categoryId) : null;
                const DisplayIcon = catInfo ? catInfo.icon : (isOut ? Star : Coins);
                const iconBg = catInfo ? catInfo.bg : (isOut ? 'bg-red-100' : 'bg-green-100');
                const iconColor = catInfo ? catInfo.color : (isOut ? 'text-red-500' : 'text-green-600');

                return (
                  <div key={t.id} className="bg-white rounded-2xl p-4 flex justify-between items-center shadow-sm">
                    <div className="flex items-center gap-4">
                      <div className={`p-3 rounded-full ${iconBg} ${iconColor}`}>
                        <DisplayIcon size={24} />
                      </div>
                      <div>
                        <p className="font-bold text-gray-700 text-lg">
                          {isOut ? (catInfo ? `买了${catInfo.name}` : '买东西') : '存入零花钱'}
                        </p>
                        <p className="text-xs text-gray-400">{t.date} {t.time}</p>
                      </div>
                    </div>
                    <span className={`text-2xl font-bold ${isOut ? 'text-red-500' : 'text-green-500'}`}>
                      {isOut ? '-' : '+'} {t.amount}
                    </span>
                  </div>
                )
              })
            )}
          </div>
        </div>
      </div>

      {modalMode === 'auth' && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-[2rem] p-8 w-full max-w-md shadow-2xl animate-fade-in">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-2xl font-bold text-gray-800 flex items-center gap-2">
                <Lock className="text-orange-500" /> 家长验证
              </h2>
              <button onClick={() => {setModalMode(null); setInputVal("");}} className="p-2 bg-gray-100 rounded-full">
                <X size={24} />
              </button>
            </div>
            <div className="bg-gray-100 rounded-xl p-4 mb-4 text-center">
               <span className="text-3xl font-mono tracking-widest text-gray-600">
                 {inputVal ? "•".repeat(inputVal.length) : "请输入密码"}
               </span>
            </div>
            <p className="text-center text-gray-400 text-sm mb-4">默认密码: 0000</p>
            <NumPad 
              onInput={handleNumInput} 
              onDelete={() => setInputVal(v => v.slice(0, -1))} 
              onConfirm={handleAuth} 
              confirmText="验证"
            />
          </div>
        </div>
      )}

      {modalMode === 'add' && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-[2rem] p-8 w-full max-w-md shadow-2xl">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-2xl font-bold text-green-600">存入零花钱</h2>
              <button onClick={() => {setModalMode(null); setInputVal("");}} className="p-2 bg-gray-100 rounded-full">
                <X size={24} />
              </button>
            </div>
            
            <button 
              onClick={giveAllowance}
              className="w-full bg-green-50 text-green-700 font-bold py-3 rounded-xl mb-6 border border-green-200 active:bg-green-100"
            >
              快速发放周薪 (¥{weeklyAllowance})
            </button>

            <div className="text-center mb-2 text-gray-500">或者输入其他金额:</div>
            <div className="flex justify-center items-end gap-2 mb-4 text-green-600">
               <span className="text-3xl font-bold">¥</span>
               <span className="text-6xl font-extrabold">{inputVal || "0"}</span>
            </div>
            <NumPad 
              onInput={handleNumInput} 
              onDelete={() => setInputVal(v => v.slice(0, -1))} 
              onConfirm={() => handleTransaction('in')}
              confirmText="确认存入" 
            />
          </div>
        </div>
      )}

      {modalMode === 'spend' && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-[2rem] p-8 w-full max-w-md shadow-2xl border-4 border-red-100">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-2xl font-bold text-red-500">
                {spendStep === 'amount' ? '我要买东西' : '你买了什么？'}
              </h2>
              <button onClick={() => {setModalMode(null); setInputVal("");}} className="p-2 bg-gray-100 rounded-full">
                <X size={24} />
              </button>
            </div>
            
            {spendStep === 'amount' ? (
              <>
                <div className="flex justify-center items-end gap-2 mb-6 text-red-500">
                   <span className="text-3xl font-bold">¥</span>
                   <span className="text-6xl font-extrabold">{inputVal || "0"}</span>
                </div>
                <div className="bg-orange-50 p-4 rounded-xl mb-4 flex gap-2 items-center text-orange-600 text-sm">
                   <Rabbit size={20} />
                   <span>花了钱，小兔子会帮你记下来哦！</span>
                </div>
                <NumPad 
                  onInput={handleNumInput} 
                  onDelete={() => setInputVal(v => v.slice(0, -1))} 
                  onConfirm={handleSpendAmountConfirm}
                  confirmText="下一步" 
                />
              </>
            ) : (
              <div className="grid grid-cols-2 gap-4">
                {CATEGORIES.map(cat => {
                  const Icon = cat.icon;
                  return (
                    <button
                      key={cat.id}
                      onClick={() => handleTransaction('out', cat.id)}
                      className={`${cat.bg} ${cat.color} p-4 rounded-2xl flex flex-col items-center gap-2 hover:scale-105 transition-transform border-2 border-transparent hover:border-current`}
                    >
                      <Icon size={40} />
                      <span className="font-bold text-lg">{cat.name}</span>
                    </button>
                  )
                })}
              </div>
            )}
          </div>
        </div>
      )}

      {modalMode === 'settings' && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
           <div className="bg-white rounded-[2rem] p-8 w-full max-w-md shadow-2xl">
             <div className="flex justify-between items-center mb-6">
              <h2 className="text-2xl font-bold text-gray-800">设置</h2>
              <button onClick={() => setModalMode(null)} className="p-2 bg-gray-100 rounded-full">
                <X size={24} />
              </button>
            </div>

            <div className="space-y-6">
              <div>
                <label className="block text-gray-500 mb-2 font-bold">每周零花钱标准 (¥)</label>
                <div className="flex items-center gap-4">
                  <button onClick={() => setWeeklyAllowance(Math.max(0, weeklyAllowance - 5))} className="p-3 bg-gray-100 rounded-lg"><Minus /></button>
                  <span className="text-3xl font-bold text-gray-700 w-20 text-center">{weeklyAllowance}</span>
                  <button onClick={() => setWeeklyAllowance(weeklyAllowance + 5)} className="p-3 bg-gray-100 rounded-lg"><Plus /></button>
                </div>
              </div>
              <hr className="border-gray-100"/>
              <div>
                 <p className="text-gray-500 mb-2 font-bold">账户管理</p>
                 <button 
                  onClick={() => {
                     if(window.confirm('确定要清空该账户的所有记录并重置余额为0吗？')) {
                       const newUsers = users.map(u => u.id === currentUser.id ? {...u, balance: 0} : u);
                       setUsers(newUsers);
                       setTransactions(transactions.filter(t => t.userId !== currentUser.id));
                       setModalMode(null);
                       selectUser(newUsers.find(u => u.id === currentUser.id));
                     }
                  }}
                  className="w-full py-3 bg-red-50 text-red-500 rounded-xl font-bold border border-red-100"
                 >
                   重置此账户余额
                 </button>
              </div>
            </div>
           </div>
        </div>
      )}

    </div>
  );
}