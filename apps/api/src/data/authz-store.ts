import { isDatabaseConfigured, query } from "../infrastructure/database.js";

const demoUserId = "user-mark";

export type UserRole = "admin" | "specialist";

const mockRoles = new Map<string, Set<UserRole>>([
  [demoUserId, new Set<UserRole>(["admin"])],
]);

export async function getUserRoles(userId?: string): Promise<UserRole[]> {
  const resolvedUserId = userId ?? demoUserId;

  if (!isDatabaseConfigured()) {
    return [...(mockRoles.get(resolvedUserId) ?? new Set<UserRole>())];
  }

  const result = await query<{ role: UserRole }>(
    `
      select role
      from user_roles
      where user_id = $1
      order by role asc
    `,
    [resolvedUserId],
  );

  return result.rows.map((row) => row.role);
}

export async function userHasRole(
  userId: string | undefined,
  role: UserRole,
): Promise<boolean> {
  return (await getUserRoles(userId)).includes(role);
}
