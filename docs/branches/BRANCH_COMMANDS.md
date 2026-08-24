# Portal App Branch Commands


> Product: Portal App  
> Status: Implementation baseline  
> Version: 0.1  
> Last reviewed: 2026-08-24  
> Technical owner: Backend, Integration & Platform Engineer  
> Mobile reviewer: Mobile UI/UX & Product Experience Engineer  
> Security/Architecture approval: TBD


```powershell
git checkout develop
git pull origin develop
git checkout -b feature/PORTAL-###-short-name
# implement, validate, commit
git push -u origin feature/PORTAL-###-short-name
```

Pull requests target `develop`. Release branches target `main`, followed by synchronization back to `develop`. Hotfixes branch from `main` and merge back to both permanent branches.
