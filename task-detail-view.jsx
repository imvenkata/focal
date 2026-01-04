import React, { useState } from 'react';

const TaskDetailView = () => {
  const [taskTitle, setTaskTitle] = useState('Gym');
  const [isCompleted, setIsCompleted] = useState(false);
  const [showColorPicker, setShowColorPicker] = useState(false);
  const [selectedColor, setSelectedColor] = useState(1);
  const [subtasks, setSubtasks] = useState([
    { id: 1, title: 'Warm up - 10 min', completed: true },
    { id: 2, title: 'Strength training', completed: false },
  ]);
  const [newSubtask, setNewSubtask] = useState('');
  const [notes, setNotes] = useState('');
  const [showMoreMenu, setShowMoreMenu] = useState(false);

  const colors = [
    { name: 'Coral', value: '#E8847C', light: '#FDF2F1', dark: '#D4706A' },
    { name: 'Sage', value: '#7BAE7F', light: '#F2F7F2', dark: '#6A9B6E' },
    { name: 'Sky', value: '#6BA3D6', light: '#F0F6FB', dark: '#5A91C4' },
    { name: 'Lavender', value: '#9B8EC2', light: '#F5F3F9', dark: '#8A7DB1' },
    { name: 'Amber', value: '#D4A853', light: '#FBF7EE', dark: '#C19642' },
    { name: 'Rose', value: '#C97B8E', light: '#FAF1F3', dark: '#B86A7D' },
    { name: 'Slate', value: '#64748B', light: '#F4F5F7', dark: '#536379' },
    { name: 'Night', value: '#5C6B7A', light: '#F3F4F5', dark: '#4B5A69' },
  ];

  const currentColor = colors[selectedColor];

  const toggleSubtask = (id) => {
    setSubtasks(prev => prev.map(s => 
      s.id === id ? { ...s, completed: !s.completed } : s
    ));
  };

  const addSubtask = () => {
    if (newSubtask.trim()) {
      setSubtasks(prev => [...prev, { id: Date.now(), title: newSubtask, completed: false }]);
      setNewSubtask('');
    }
  };

  return (
    <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-stone-100 via-stone-50 to-amber-50/20 p-8">
      {/* iPhone Frame */}
      <div className="relative w-[390px] h-[844px] bg-stone-900 rounded-[55px] p-3 shadow-2xl">
        <div className="relative w-full h-full bg-[#F8F7F4] rounded-[45px] overflow-hidden flex flex-col">
          
          {/* Dynamic Island */}
          <div className="absolute top-3 left-1/2 -translate-x-1/2 w-[126px] h-[37px] bg-black rounded-full z-50" />

          {/* Colored Header Section */}
          <div 
            className="relative pt-16 pb-6 px-5"
            style={{ backgroundColor: currentColor.light }}
          >
            {/* Timeline decoration */}
            <div 
              className="absolute left-8 top-0 bottom-0 w-0.5 border-l-2 border-dashed opacity-30"
              style={{ borderColor: currentColor.value }}
            />

            {/* Top Actions */}
            <div className="flex justify-between items-start mb-6 relative z-10">
              <button 
                className="w-10 h-10 rounded-full flex items-center justify-center transition-all hover:scale-105"
                style={{ backgroundColor: currentColor.value }}
              >
                <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>

              <div className="relative">
                <button 
                  onClick={() => setShowMoreMenu(!showMoreMenu)}
                  className="w-10 h-10 rounded-full flex items-center justify-center transition-all hover:scale-105"
                  style={{ backgroundColor: currentColor.value }}
                >
                  <svg className="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 24 24">
                    <circle cx="12" cy="6" r="2" />
                    <circle cx="12" cy="12" r="2" />
                    <circle cx="12" cy="18" r="2" />
                  </svg>
                </button>

                {/* More Menu Dropdown */}
                {showMoreMenu && (
                  <div className="absolute right-0 top-12 w-48 bg-white rounded-2xl shadow-xl border border-stone-100 overflow-hidden z-50 animate-fadeIn">
                    {[
                      { icon: '📋', label: 'Duplicate' },
                      { icon: '📤', label: 'Share' },
                      { icon: '📌', label: 'Pin to Top' },
                      { icon: '📁', label: 'Move to...' },
                    ].map((item, i) => (
                      <button key={i} className="w-full flex items-center gap-3 px-4 py-3 hover:bg-stone-50 transition-colors text-left">
                        <span>{item.icon}</span>
                        <span className="text-sm font-medium text-stone-700">{item.label}</span>
                      </button>
                    ))}
                  </div>
                )}
              </div>
            </div>

            {/* Task Header */}
            <div className="flex items-start gap-4 relative z-10">
              {/* Task Pill with Color Picker */}
              <div className="relative">
                <div 
                  className="w-20 h-28 rounded-3xl flex items-center justify-center shadow-lg transition-transform hover:scale-105"
                  style={{ backgroundColor: currentColor.value }}
                >
                  <span className="text-4xl">🏋️</span>
                </div>
                
                {/* Color Picker Button */}
                <button
                  onClick={() => setShowColorPicker(!showColorPicker)}
                  className="absolute -bottom-2 -left-2 w-9 h-9 rounded-full bg-white shadow-md flex items-center justify-center border-2 transition-transform hover:scale-110"
                  style={{ borderColor: currentColor.value }}
                >
                  <span className="text-lg">🎨</span>
                </button>

                {/* Color Picker Popup */}
                {showColorPicker && (
                  <div className="absolute top-full left-0 mt-4 bg-white rounded-2xl shadow-xl p-3 z-50 animate-fadeIn">
                    <div className="grid grid-cols-4 gap-2">
                      {colors.map((color, i) => (
                        <button
                          key={i}
                          onClick={() => {
                            setSelectedColor(i);
                            setShowColorPicker(false);
                          }}
                          className={`w-9 h-9 rounded-full transition-all ${
                            selectedColor === i ? 'ring-2 ring-offset-2 scale-110' : 'hover:scale-105'
                          }`}
                          style={{ backgroundColor: color.value, ringColor: color.value }}
                        />
                      ))}
                    </div>
                  </div>
                )}
              </div>

              {/* Title & Time */}
              <div className="flex-1 pt-2">
                <p 
                  className="text-sm font-medium mb-1 opacity-70"
                  style={{ color: currentColor.dark }}
                >
                  12:00 – 13:00 (1 hr)
                </p>
                <input
                  type="text"
                  value={taskTitle}
                  onChange={(e) => setTaskTitle(e.target.value)}
                  className="text-2xl font-bold bg-transparent outline-none w-full border-b-2 border-transparent focus:border-current pb-1 transition-colors"
                  style={{ color: currentColor.dark, borderColor: 'transparent' }}
                />
              </div>

              {/* Completion Checkbox */}
              <button
                onClick={() => setIsCompleted(!isCompleted)}
                className={`w-8 h-8 rounded-full border-2 flex items-center justify-center transition-all mt-4 ${
                  isCompleted ? 'bg-emerald-500 border-emerald-500' : ''
                }`}
                style={{ borderColor: isCompleted ? undefined : currentColor.dark }}
              >
                {isCompleted && (
                  <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                  </svg>
                )}
              </button>
            </div>
          </div>

          {/* Details Card */}
          <div className="flex-1 bg-white rounded-t-[32px] -mt-4 shadow-[0_-4px_24px_rgba(0,0,0,0.08)] overflow-hidden flex flex-col relative z-20">
            <div className="flex-1 overflow-y-auto">
              {/* Date, Time, Alerts Section */}
              <div className="mx-5 mt-6 bg-stone-50 rounded-2xl overflow-hidden">
                {/* Date Row */}
                <button className="w-full flex items-center justify-between p-4 hover:bg-stone-100 transition-colors">
                  <div className="flex items-center gap-3">
                    <div 
                      className="w-9 h-9 rounded-xl flex items-center justify-center"
                      style={{ backgroundColor: `${currentColor.value}20` }}
                    >
                      <svg className="w-5 h-5" style={{ color: currentColor.value }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                      </svg>
                    </div>
                    <span className="font-medium text-stone-800">Sat, 3 Jan 2026</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-medium" style={{ color: currentColor.value }}>Today</span>
                    <svg className="w-4 h-4 text-stone-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                  </div>
                </button>

                <div className="h-px bg-stone-200 mx-4" />

                {/* Time Row */}
                <button className="w-full flex items-center justify-between p-4 hover:bg-stone-100 transition-colors">
                  <div className="flex items-center gap-3">
                    <div 
                      className="w-9 h-9 rounded-xl flex items-center justify-center"
                      style={{ backgroundColor: `${currentColor.value}20` }}
                    >
                      <svg className="w-5 h-5" style={{ color: currentColor.value }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                    </div>
                    <span className="font-medium text-stone-800">12:00 – 13:00</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-sm text-stone-500">1 hr</span>
                    <svg className="w-4 h-4 text-stone-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                  </div>
                </button>

                <div className="h-px bg-stone-200 mx-4" />

                {/* Alerts Row */}
                <button className="w-full flex items-center justify-between p-4 hover:bg-stone-100 transition-colors">
                  <div className="flex items-center gap-3">
                    <div 
                      className="w-9 h-9 rounded-xl flex items-center justify-center"
                      style={{ backgroundColor: `${currentColor.value}20` }}
                    >
                      <svg className="w-5 h-5" style={{ color: currentColor.value }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                      </svg>
                    </div>
                    <span className="font-medium text-stone-800">3 Alerts</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-sm text-stone-500">Nudge</span>
                    <svg className="w-4 h-4 text-stone-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                  </div>
                </button>
              </div>

              {/* Repeat & Energy Pills */}
              <div className="flex gap-3 px-5 mt-4">
                <button className="flex-1 flex items-center justify-center gap-2 py-3 bg-stone-100 rounded-2xl hover:bg-stone-200 transition-colors">
                  <svg className="w-5 h-5 text-stone-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                  </svg>
                  <span className="font-medium text-stone-700">Repeat</span>
                  <span className="text-[10px] font-bold px-1.5 py-0.5 bg-amber-100 text-amber-700 rounded">PRO</span>
                </button>
                <button 
                  className="flex-1 flex items-center justify-center gap-2 py-3 rounded-2xl transition-colors"
                  style={{ backgroundColor: `${currentColor.value}15` }}
                >
                  <span className="text-lg">🔥</span>
                  <span className="font-medium" style={{ color: currentColor.value }}>Energy</span>
                </button>
              </div>

              {/* Subtasks Section */}
              <div className="px-5 mt-6">
                <p className="text-xs font-semibold text-stone-500 uppercase tracking-wide mb-3">Subtasks</p>
                <div className="bg-stone-50 rounded-2xl overflow-hidden">
                  {/* Existing Subtasks */}
                  {subtasks.map((subtask, index) => (
                    <div key={subtask.id}>
                      <div className="flex items-center gap-3 p-4">
                        <button
                          onClick={() => toggleSubtask(subtask.id)}
                          className={`w-6 h-6 rounded-lg border-2 flex items-center justify-center transition-all flex-shrink-0 ${
                            subtask.completed ? 'bg-emerald-500 border-emerald-500' : 'border-stone-300'
                          }`}
                        >
                          {subtask.completed && (
                            <svg className="w-3.5 h-3.5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                            </svg>
                          )}
                        </button>
                        <span className={`font-medium transition-all ${
                          subtask.completed ? 'text-stone-400 line-through' : 'text-stone-700'
                        }`}>
                          {subtask.title}
                        </span>
                      </div>
                      {index < subtasks.length - 1 && <div className="h-px bg-stone-200 mx-4" />}
                    </div>
                  ))}
                  
                  {subtasks.length > 0 && <div className="h-px bg-stone-200 mx-4" />}
                  
                  {/* Add Subtask Input */}
                  <div className="flex items-center gap-3 p-4">
                    <div className="w-6 h-6 rounded-lg border-2 border-dashed border-stone-300 flex-shrink-0" />
                    <input
                      type="text"
                      value={newSubtask}
                      onChange={(e) => setNewSubtask(e.target.value)}
                      onKeyDown={(e) => e.key === 'Enter' && addSubtask()}
                      placeholder="Add Subtask"
                      className="flex-1 bg-transparent outline-none text-stone-700 placeholder:text-stone-400"
                    />
                    {newSubtask && (
                      <button 
                        onClick={addSubtask}
                        className="w-7 h-7 rounded-full flex items-center justify-center transition-all"
                        style={{ backgroundColor: currentColor.value }}
                      >
                        <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M12 4v16m8-8H4" />
                        </svg>
                      </button>
                    )}
                  </div>
                </div>
              </div>

              {/* Notes Section */}
              <div className="px-5 mt-6 pb-6">
                <p className="text-xs font-semibold text-stone-500 uppercase tracking-wide mb-3">Notes</p>
                <textarea
                  value={notes}
                  onChange={(e) => setNotes(e.target.value)}
                  placeholder="Add notes, meeting links or phone numbers..."
                  className="w-full h-28 bg-stone-50 rounded-2xl p-4 text-stone-700 placeholder:text-stone-400 outline-none resize-none focus:ring-2 transition-all"
                  style={{ '--tw-ring-color': currentColor.value }}
                />
              </div>
            </div>

            {/* Delete Button */}
            <div className="p-5 pt-2 border-t border-stone-100">
              <button className="w-full flex items-center justify-center gap-2 py-4 bg-red-50 hover:bg-red-100 rounded-2xl transition-colors group">
                <svg className="w-5 h-5 text-red-500 group-hover:scale-110 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
                <span className="font-semibold text-red-500">Delete Task</span>
              </button>
            </div>

            {/* Home Indicator */}
            <div className="flex justify-center pb-2">
              <div className="w-32 h-1 bg-stone-900 rounded-full" />
            </div>
          </div>
        </div>
      </div>

      {/* Design Specs */}
      <div className="ml-12 max-w-md space-y-5">
        <div>
          <h2 className="text-2xl font-bold text-stone-800 mb-2">Task Detail View</h2>
          <p className="text-stone-500">Full task editing with colored header</p>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-4">View Anatomy</h3>
          <div className="space-y-3">
            {[
              { section: 'Header', desc: 'Task color background, pill preview, title input' },
              { section: 'Actions', desc: 'Close (X), More menu (...), Complete checkbox' },
              { section: 'Color Picker', desc: 'Floating button on pill, 8 color grid' },
              { section: 'Details Card', desc: 'Date, Time, Alerts with chevron navigation' },
              { section: 'Feature Pills', desc: 'Repeat (PRO), Energy level selector' },
              { section: 'Subtasks', desc: 'Checklist with add input' },
              { section: 'Notes', desc: 'Multiline text area' },
              { section: 'Delete', desc: 'Destructive action at bottom' },
            ].map((item, i) => (
              <div key={i} className="flex items-start gap-3">
                <div 
                  className="w-2 h-2 rounded-full mt-1.5 flex-shrink-0"
                  style={{ backgroundColor: colors[i % colors.length].value }}
                />
                <div>
                  <p className="font-medium text-stone-700 text-sm">{item.section}</p>
                  <p className="text-xs text-stone-500">{item.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-3">Interactions</h3>
          <ul className="space-y-2 text-sm text-stone-600">
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 bg-emerald-500 rounded-full" />
              Tap title to edit inline
            </li>
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 bg-emerald-500 rounded-full" />
              Tap color picker to change theme
            </li>
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 bg-emerald-500 rounded-full" />
              Swipe subtask to delete
            </li>
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 bg-emerald-500 rounded-full" />
              Drag subtasks to reorder
            </li>
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 bg-emerald-500 rounded-full" />
              Auto-save on any change
            </li>
          </ul>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-3">Swift Implementation</h3>
          <div className="text-xs font-mono text-stone-600 bg-stone-50 rounded-xl p-3 space-y-1">
            <p className="text-stone-400">// Present as full screen cover</p>
            <p>.fullScreenCover(item: $selectedTask) {'{'}</p>
            <p className="pl-3">task in</p>
            <p className="pl-3">TaskDetailView(task: task)</p>
            <p className="pl-6">.transition(.move(edge: .bottom))</p>
            <p>{'}'}</p>
            <p></p>
            <p className="text-stone-400">// Color-adaptive header</p>
            <p>ZStack(alignment: .top) {'{'}</p>
            <p className="pl-3">task.color.light</p>
            <p className="pl-6">.ignoresSafeArea()</p>
            <p className="pl-3">VStack {'{'} ... {'}'}</p>
            <p>{'}'}</p>
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-3">More Menu Actions</h3>
          <div className="grid grid-cols-2 gap-2">
            {[
              { icon: '📋', label: 'Duplicate' },
              { icon: '📤', label: 'Share' },
              { icon: '📌', label: 'Pin' },
              { icon: '📁', label: 'Move' },
              { icon: '⏸️', label: 'Skip Once' },
              { icon: '🔗', label: 'Copy Link' },
            ].map((item, i) => (
              <div key={i} className="flex items-center gap-2 text-sm text-stone-600">
                <span>{item.icon}</span>
                <span>{item.label}</span>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-gradient-to-br from-amber-50 to-orange-50 rounded-2xl p-5 border border-amber-200/50">
          <h3 className="font-semibold text-amber-800 mb-2">💡 UX Tips</h3>
          <ul className="text-sm text-amber-700 space-y-1">
            <li>• Confirm before delete (haptic + alert)</li>
            <li>• Undo toast after completion toggle</li>
            <li>• Keyboard toolbar for notes navigation</li>
            <li>• URL detection in notes (auto-link)</li>
          </ul>
        </div>
      </div>

      <style jsx>{`
        @keyframes fadeIn {
          from { opacity: 0; transform: scale(0.95); }
          to { opacity: 1; transform: scale(1); }
        }
        .animate-fadeIn {
          animation: fadeIn 0.2s ease-out;
        }
      `}</style>
    </div>
  );
};

export default TaskDetailView;
