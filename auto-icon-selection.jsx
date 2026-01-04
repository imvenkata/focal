import React, { useState, useEffect } from 'react';

export default function AutoIconSelection() {
  const [taskTitle, setTaskTitle] = useState('');
  const [currentIcon, setCurrentIcon] = useState('📝');
  const [currentColor, setCurrentColor] = useState('#7BAE7F');
  const [showPicker, setShowPicker] = useState(false);
  const [isAutoSuggested, setIsAutoSuggested] = useState(false);

  const colors = [
    { name: 'Coral', value: '#E8847C', light: '#FDF2F1' },
    { name: 'Sage', value: '#7BAE7F', light: '#F2F7F2' },
    { name: 'Sky', value: '#6BA3D6', light: '#F0F6FB' },
    { name: 'Lavender', value: '#9B8EC2', light: '#F5F3F9' },
    { name: 'Amber', value: '#D4A853', light: '#FBF7EE' },
    { name: 'Rose', value: '#C97B8E', light: '#FAF1F3' },
  ];

  const iconMap = {
    'gym': { icon: '🏋️', color: '#7BAE7F' },
    'workout': { icon: '🏋️', color: '#7BAE7F' },
    'exercise': { icon: '🏃', color: '#7BAE7F' },
    'run': { icon: '🏃', color: '#7BAE7F' },
    'running': { icon: '🏃', color: '#7BAE7F' },
    'yoga': { icon: '🧘', color: '#9B8EC2' },
    'meditation': { icon: '🧘', color: '#9B8EC2' },
    'meeting': { icon: '👥', color: '#6BA3D6' },
    'call': { icon: '📞', color: '#6BA3D6' },
    'phone': { icon: '📞', color: '#6BA3D6' },
    'work': { icon: '💼', color: '#6BA3D6' },
    'email': { icon: '📧', color: '#6BA3D6' },
    'office': { icon: '🏢', color: '#6BA3D6' },
    'breakfast': { icon: '🍳', color: '#D4A853' },
    'lunch': { icon: '🍽️', color: '#D4A853' },
    'dinner': { icon: '🍽️', color: '#D4A853' },
    'coffee': { icon: '☕', color: '#D4A853' },
    'cook': { icon: '👨‍🍳', color: '#D4A853' },
    'study': { icon: '📚', color: '#9B8EC2' },
    'read': { icon: '📖', color: '#9B8EC2' },
    'reading': { icon: '📖', color: '#9B8EC2' },
    'learn': { icon: '🎓', color: '#9B8EC2' },
    'sleep': { icon: '😴', color: '#9B8EC2' },
    'wake': { icon: '☀️', color: '#E8847C' },
    'morning': { icon: '🌅', color: '#E8847C' },
    'night': { icon: '🌙', color: '#9B8EC2' },
    'clean': { icon: '🧹', color: '#D4A853' },
    'laundry': { icon: '👕', color: '#D4A853' },
    'shopping': { icon: '🛍️', color: '#C97B8E' },
    'shop': { icon: '🛍️', color: '#C97B8E' },
    'grocery': { icon: '🛒', color: '#D4A853' },
    'friends': { icon: '👯', color: '#C97B8E' },
    'party': { icon: '🎉', color: '#C97B8E' },
    'doctor': { icon: '👨‍⚕️', color: '#6BA3D6' },
    'medicine': { icon: '💊', color: '#E8847C' },
    'write': { icon: '✍️', color: '#9B8EC2' },
    'music': { icon: '🎵', color: '#9B8EC2' },
    'code': { icon: '💻', color: '#6BA3D6' },
    'travel': { icon: '✈️', color: '#6BA3D6' },
    'drive': { icon: '🚗', color: '#6BA3D6' },
  };

  const allIcons = ['☀️', '🌙', '🏋️', '🏃', '🧘', '💼', '👥', '📞', '💻', '📧', '📚', '📖', '✍️', '🍽️', '☕', '🛒', '🧹', '💊', '🎨', '🎵', '🎮', '✈️', '🎯', '🎉'];

  const findIcon = (text) => {
    if (!text) return null;
    const lower = text.toLowerCase();
    if (iconMap[lower]) return iconMap[lower];
    for (const [keyword, data] of Object.entries(iconMap)) {
      if (lower.includes(keyword)) return data;
    }
    const words = lower.split(' ');
    for (const word of words) {
      if (iconMap[word]) return iconMap[word];
    }
    return null;
  };

  useEffect(() => {
    const match = findIcon(taskTitle);
    if (match) {
      setCurrentIcon(match.icon);
      setCurrentColor(match.color);
      setIsAutoSuggested(true);
    } else if (taskTitle === '') {
      setCurrentIcon('📝');
      setCurrentColor('#7BAE7F');
      setIsAutoSuggested(false);
    }
  }, [taskTitle]);

  const handleIconSelect = (icon) => {
    setCurrentIcon(icon);
    setIsAutoSuggested(false);
    setShowPicker(false);
  };

  const demoTasks = [
    { title: 'Gym', icon: '🏋️' },
    { title: 'Meeting', icon: '👥' },
    { title: 'Lunch', icon: '🍽️' },
    { title: 'Study', icon: '📚' },
    { title: 'Morning yoga', icon: '🧘' },
    { title: 'Call mom', icon: '📞' },
  ];

  const getColorLight = () => {
    const found = colors.find(c => c.value === currentColor);
    return found ? found.light : '#F2F7F2';
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-stone-100 via-stone-50 to-amber-50/30 p-8 flex items-center justify-center gap-12">
      
      {/* iPhone Frame */}
      <div className="w-[390px] h-[844px] bg-stone-900 rounded-[55px] p-3 shadow-2xl">
        <div className="w-full h-full bg-[#F8F7F4] rounded-[45px] overflow-hidden relative flex flex-col">
          
          {/* Dynamic Island */}
          <div className="absolute top-3 left-1/2 -translate-x-1/2 w-[126px] h-[37px] bg-black rounded-full z-50" />

          {/* Header */}
          <div className="px-5 pt-16 pb-4">
            <div className="flex justify-between items-center">
              <span className="text-stone-500 font-medium">Cancel</span>
              <span className="text-stone-800 font-semibold text-lg">New Task</span>
              <span className={`font-semibold ${taskTitle ? 'text-amber-600' : 'text-stone-300'}`}>Save</span>
            </div>
          </div>

          {/* Task Preview Card */}
          <div className="px-5 mb-4">
            <div 
              className="rounded-2xl p-4 transition-all duration-300"
              style={{ backgroundColor: getColorLight() }}
            >
              <div className="flex items-center gap-4">
                {/* Icon Button */}
                <div className="relative">
                  <button
                    onClick={() => setShowPicker(!showPicker)}
                    className="w-16 h-16 rounded-2xl flex items-center justify-center shadow-sm transition-transform hover:scale-105 active:scale-95"
                    style={{ backgroundColor: currentColor }}
                  >
                    <span className="text-3xl">{currentIcon}</span>
                  </button>
                  
                  {isAutoSuggested && (
                    <>
                      <div className="absolute -top-1 -right-1 w-5 h-5 bg-emerald-500 rounded-full flex items-center justify-center shadow">
                        <span className="text-white text-xs">✓</span>
                      </div>
                      <div className="absolute -bottom-1 -left-1 w-5 h-5 bg-amber-400 rounded-full flex items-center justify-center text-[10px]">
                        ✨
                      </div>
                    </>
                  )}
                </div>

                {/* Title Input */}
                <div className="flex-1">
                  <input
                    type="text"
                    value={taskTitle}
                    onChange={(e) => setTaskTitle(e.target.value)}
                    placeholder="What's your task?"
                    className="w-full text-xl font-semibold text-stone-800 bg-transparent outline-none placeholder:text-stone-400"
                  />
                  {isAutoSuggested && (
                    <p className="text-xs text-stone-500 mt-1 flex items-center gap-1">
                      <span>✨</span> Auto-suggested icon
                    </p>
                  )}
                </div>
              </div>
            </div>
          </div>

          {/* Icon Picker */}
          {showPicker && (
            <div className="px-5 mb-4">
              <div className="bg-white rounded-2xl p-4 shadow-lg border border-stone-100">
                <div className="flex justify-between items-center mb-3">
                  <p className="text-xs font-semibold text-stone-500 uppercase tracking-wide">Choose Icon</p>
                  <button 
                    onClick={() => setShowPicker(false)}
                    className="w-6 h-6 rounded-full bg-stone-100 flex items-center justify-center text-stone-500"
                  >
                    ✕
                  </button>
                </div>
                <div className="grid grid-cols-6 gap-2">
                  {allIcons.map((icon, i) => (
                    <button
                      key={i}
                      onClick={() => handleIconSelect(icon)}
                      className={`w-11 h-11 rounded-xl flex items-center justify-center text-xl transition-all ${
                        currentIcon === icon ? 'bg-stone-800 scale-110' : 'bg-stone-50 hover:bg-stone-100'
                      }`}
                    >
                      {icon}
                    </button>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* Demo Tasks */}
          <div className="px-5 mb-4">
            <p className="text-xs font-semibold text-stone-500 uppercase tracking-wide mb-3">Try typing these</p>
            <div className="flex flex-wrap gap-2">
              {demoTasks.map((demo, i) => (
                <button
                  key={i}
                  onClick={() => setTaskTitle(demo.title)}
                  className="flex items-center gap-1.5 px-3 py-2 bg-white rounded-xl border border-stone-200 hover:border-stone-300 hover:bg-stone-50 transition-all"
                >
                  <span>{demo.icon}</span>
                  <span className="text-sm font-medium text-stone-600">{demo.title}</span>
                </button>
              ))}
            </div>
          </div>

          {/* Color Selection */}
          <div className="px-5 mb-4">
            <p className="text-xs font-semibold text-stone-500 uppercase tracking-wide mb-3">Color</p>
            <div className="flex gap-3">
              {colors.map((color, i) => (
                <button
                  key={i}
                  onClick={() => setCurrentColor(color.value)}
                  className={`w-10 h-10 rounded-full transition-all flex items-center justify-center ${
                    currentColor === color.value ? 'scale-110 ring-2 ring-offset-2' : 'hover:scale-105'
                  }`}
                  style={{ 
                    backgroundColor: color.value,
                    '--tw-ring-color': color.value
                  }}
                >
                  {currentColor === color.value && (
                    <span className="text-white">✓</span>
                  )}
                </button>
              ))}
            </div>
          </div>

          {/* Info Card */}
          <div className="px-5 mt-auto mb-4">
            <div className="bg-gradient-to-r from-amber-50 to-orange-50 rounded-2xl p-4 border border-amber-100">
              <div className="flex gap-3">
                <div className="w-10 h-10 bg-amber-100 rounded-xl flex items-center justify-center text-xl flex-shrink-0">
                  ✨
                </div>
                <div>
                  <h4 className="font-semibold text-amber-800 mb-1">Smart Icon Selection</h4>
                  <p className="text-xs text-amber-700 leading-relaxed">
                    Icons and colors are automatically suggested as you type. Tap the icon to choose manually.
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* Create Button */}
          <div className="px-5 pb-4">
            <button
              disabled={!taskTitle}
              className={`w-full py-4 rounded-2xl font-semibold text-white transition-all ${
                taskTitle ? 'opacity-100' : 'opacity-50'
              }`}
              style={{ 
                backgroundColor: currentColor,
                boxShadow: taskTitle ? `0 8px 24px ${currentColor}66` : 'none'
              }}
            >
              Create Task
            </button>
          </div>

          {/* Home Indicator */}
          <div className="flex justify-center pb-2">
            <div className="w-32 h-1 bg-stone-900 rounded-full" />
          </div>
        </div>
      </div>

      {/* Documentation */}
      <div className="max-w-md">
        <h2 className="text-2xl font-bold text-stone-800 mb-2">Auto Icon Selection</h2>
        <p className="text-stone-500 mb-6">Smart icon & color suggestions based on task title</p>

        <div className="bg-white rounded-2xl p-5 mb-4 border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-4">Keyword Examples</h3>
          <div className="grid grid-cols-2 gap-2">
            {[
              { word: 'gym', icon: '🏋️' },
              { word: 'meeting', icon: '👥' },
              { word: 'lunch', icon: '🍽️' },
              { word: 'study', icon: '📚' },
              { word: 'yoga', icon: '🧘' },
              { word: 'call', icon: '📞' },
              { word: 'coffee', icon: '☕' },
              { word: 'sleep', icon: '😴' },
            ].map((item, i) => (
              <div key={i} className="flex items-center gap-2 p-2 bg-stone-50 rounded-lg">
                <span>{item.icon}</span>
                <span className="text-sm text-stone-600">{item.word}</span>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-3">How It Works</h3>
          <ol className="text-sm text-stone-600 leading-relaxed space-y-2 list-decimal list-inside">
            <li>User types task title</li>
            <li>System matches keywords (40+ mapped)</li>
            <li>Icon & color update instantly</li>
            <li>User can override manually</li>
          </ol>
        </div>
      </div>
    </div>
  );
}
